
class PrawnPDFImage < Prawn::Images::Image
  # Abstracts out accessing values from our source PDF image
  class Image
    def initialize(image_stream)
      self.image_stream = image_stream
    end

    def height
      image_stream.hash[:Height]
    end

    def filter
      image_stream.hash[:Filter]
    end

    def width
      image_stream.hash[:Width]
    end

    def bits_per_component
      image_stream.hash[:BitsPerComponent]
    end

    def data
      image_stream.data
    end

    def decode_parms
      image_stream.hash[:DecodeParms]
    end

    def colorspace
      image_stream.hash[:ColorSpace]
    end

    def soft_mask?
      image_stream.hash.key? :SMask
    end

    def soft_mask_filter
      soft_mask.hash[:Filter]
    end

    def soft_mask_decode_parms
      soft_mask.hash[:DecodeParms]
    end

    private

    attr_accessor :image_stream

    def soft_mask
      image_stream.hash[:SMask]
    end
  end
end
