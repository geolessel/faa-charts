defmodule Charts.Parser.DTPP.XMLTest do
  use ExUnit.Case, async: true
  doctest Charts.Parser.DTPP.XML

  setup do
    xml = File.stream!("./test/support/dtpp-example.xml", [], 2048)
    {:ok, %{xml_stream: xml}}
  end

  describe "parse_stream" do
    test "finds the dtpp", %{xml_stream: xml_stream} do
      dtpp =
        with {:ok, result} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          result
          |> Map.get(:dtpp)
        end

      assert %Charts.DTPP{
               cycle: "2008",
               from_edate: "0901Z  07/16/20",
               to_edate: "0901Z  08/13/20"
             } == dtpp
    end

    test "finds the states", %{xml_stream: xml_stream} do
      expected = ["AR", "CA"]

      states =
        with {:ok, result} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          result
          |> Map.get(:states)
          |> Enum.map(& &1.abbreviation)
          |> Enum.sort()
        end

      assert states == expected
    end

    test "finds the cities", %{xml_stream: xml_stream} do
      expected = ["CARLSBAD", "CONWAY", "LITTLE ROCK", "OCEANSIDE"]

      actual =
        with {:ok, result} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          result
          |> Map.get(:cities)
          |> Enum.map(& &1.name)
          |> Enum.sort()
        end

      assert expected == actual
    end

    test "associates cities with states", %{xml_stream: xml_stream} do
      oceanside =
        with {:ok, %{cities: cities}} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          cities
          |> Enum.find(&(&1.name == "OCEANSIDE"))
        end

      assert oceanside.state.abbreviation == "CA"
    end

    test "finds the airports", %{xml_stream: xml_stream} do
      expected = [
        "BILL AND HILLARY CLINTON NATIONAL/ADAMS FIELD",
        "BOB MAXWELL MEMORIAL AIRFIELD",
        "CAMP PENDLETON MCAS (MUNN FIELD)",
        "CANTRELL FIELD",
        "MC CLELLAN-PALOMAR"
      ]

      actual =
        with {:ok, result} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          result
          |> Map.get(:airports)
          |> Enum.map(& &1.name)
          |> Enum.sort()
        end

      assert expected == actual
    end

    test "associates airports with cities", %{xml_stream: xml_stream} do
      conway =
        with {:ok, %{airports: airports}} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          airports
          |> Enum.find(&(&1.icao_ident == "KCXW"))
        end

      assert conway.city.name == "CONWAY"
    end

    test "finds the charts and associates them with airport and dtpp", %{xml_stream: xml_stream} do
      chart =
        with {:ok, %{charts: charts}} <- Charts.Parser.DTPP.XML.parse_stream(xml_stream) do
          charts
          |> Enum.find(&(&1.pdf_name == "00233IL4L.PDF"))
        end

      assert %Charts.Chart{
               airport: %Charts.Airport{
                 alnum: "233",
                 apt_ident: "LIT",
                 city: %Charts.City{
                   name: "LITTLE ROCK",
                   state: %Charts.State{abbreviation: "AR", name: "Arkansas"},
                   volume: "SC-1"
                 },
                 icao_ident: "KLIT",
                 military: "N",
                 name: "BILL AND HILLARY CLINTON NATIONAL/ADAMS FIELD"
               },
               chartseq: "50750",
               chart_code: "IAP",
               chart_name: "ILS OR LOC RWY 04L",
               dtpp: %Charts.DTPP{
                 cycle: "2008",
                 from_edate: "0901Z  07/16/20",
                 to_edate: "0901Z  08/13/20"
               },
               useraction: nil,
               pdf_name: "00233IL4L.PDF",
               cn_flg: "N",
               cnsection: nil,
               cnpage: nil,
               bvsection: nil,
               bvpage: "221",
               procuid: "1043",
               two_colored: "N",
               civil: "D",
               faanfd18: "I04L",
               copter: "N",
               amdtnum: "26B",
               amdtdate: "10/11/2018"
             } == chart
    end
  end
end
