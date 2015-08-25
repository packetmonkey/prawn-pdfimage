require 'pdf-reader'

class PrawnPDFImage < Prawn::Images::Image
  # Abstracts out accessing values from our source PDF
  class PDF
    def initialize(pdf_blob)
      self.reader = ::PDF::Reader.new StringIO.new(pdf_blob)
    end

    def image_filter
      image_stream.hash[:Filter]
    end

    def image_height
      image_stream.hash[:Height]
    end

    def image_width
      image_stream.hash[:Width]
    end

    def image_bits_per_component
      image_stream.hash[:BitsPerComponent]
    end

    def image_decode_parms
      image_stream.hash[:DecodeParms]
    end

    def image_data
      image_stream.data
    end

    def image_colorspace
      image_stream.hash[:ColorSpace]
    end

    def soft_mask
      image_stream.hash[:SMask]
    end

    def soft_mask?
      image_stream.hash.key? :SMask
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
