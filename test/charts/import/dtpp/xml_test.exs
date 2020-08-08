defmodule Charts.Import.DTPP.XMLTest do
  use ExUnit.Case, async: true
  doctest Charts.Import.DTPP.XML

  setup do
    xml = File.stream!("./test/support/dtpp-example.xml", [], 2048)
    {:ok, %{xml_stream: xml}}
  end

  describe "parse_stream" do
    test "finds the states", %{xml_stream: xml_stream} do
      expected = ["AR", "CA"]

      states =
        with {:ok, result} <- Charts.Import.DTPP.XML.parse_stream(xml_stream) do
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
        with {:ok, result} <- Charts.Import.DTPP.XML.parse_stream(xml_stream) do
          result
          |> Map.get(:cities)
          |> Enum.map(& &1.name)
          |> Enum.sort()
        end

      assert expected == actual
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
        with {:ok, result} <- Charts.Import.DTPP.XML.parse_stream(xml_stream) do
          result
          |> Map.get(:airports)
          |> Enum.map(& &1.name)
          |> Enum.sort()
        end

      assert expected == actual
    end

    test "associates cities with states"

    test "associates airports with cities"
  end
end
