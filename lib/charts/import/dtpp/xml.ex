defmodule Charts.Import.DTPP.XML do
  def parse_stream(xml_stream) do
    Saxy.parse_stream(xml_stream, Charts.Import.SaxyXMLHandler, [])
  end
end
