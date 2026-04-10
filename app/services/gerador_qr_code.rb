require "rqrcode"

class GeradorQrCode
  def self.svg_para(url, modulo: 6)
    qr = RQRCode::QRCode.new(url)
    qr.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: modulo,
      standalone: true,
      use_path: true
    )
  end

  def self.png_para(url, tamanho: 600)
    qr = RQRCode::QRCode.new(url)
    qr.as_png(
      bit_depth: 1,
      border_modules: 2,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: tamanho
    )
  end
end
