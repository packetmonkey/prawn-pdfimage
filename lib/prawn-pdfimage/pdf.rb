require 'pdf-reader'
require_relative 'image'

class PrawnPDFImage < Prawn::Images::Image
  # Abstracts out accessing values from our source PDF
  class PDF
    def initialize(pdf_blob)
      self.reader = ::PDF::Reader.new StringIO.new(pdf_blob)
    end

    def image
      Image.new page.xobjects.first[1]
    end

    def soft_mask
      image_stream.hash[:SMask]
    end

    def indexed_colorspace_base
      image_stream.hash[:ColorSpace][1]
    end

    def indexed_colorspace_lookup
      image_stream.hash[:ColorSpace][3]
    end

    private

    attr_accessor :reader

    def image_stream
      page.xobjects.first[1]
    end

    def page
      reader.page 1
    end
  end
end
