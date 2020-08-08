defmodule Charts.Parser.DTPP.XML do
  def parse_stream(xml_stream) do
    Saxy.parse_stream(xml_stream, Charts.Parser.DTPP.SaxyXMLHandler, [])
  end

  def parse_stream!(xml_stream) do
    {:ok, result} = parse_stream(xml_stream)
    result
  end

  def parse_file(path), do: parse_stream(File.stream!(path, [], 2048))

  def parse_file!(path), do: parse_stream!(File.stream!(path, [], 2048))
end
