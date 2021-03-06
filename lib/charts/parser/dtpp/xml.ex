defmodule FaaCharts.Parser.DTPP.XML do
  def parse_string(string) do
    Saxy.parse_string(string, FaaCharts.Parser.DTPP.SaxyXMLHandler, [])
  end

  def parse_string!(string) do
    {:ok, result} = parse_string(string)
    result
  end

  def parse_stream(xml_stream) do
    Saxy.parse_stream(xml_stream, FaaCharts.Parser.DTPP.SaxyXMLHandler, [])
  end

  def parse_stream!(xml_stream) do
    {:ok, result} = parse_stream(xml_stream)
    result
  end

  def parse_file(path), do: parse_stream(File.stream!(path, [], 2048))

  def parse_file!(path), do: parse_stream!(File.stream!(path, [], 2048))
end
