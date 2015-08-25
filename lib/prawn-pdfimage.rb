require 'prawn'
require 'pdf-reader'

# Implements support for pulling an image out of an existing PDF and adds
# that image to a prawn document.
#
# In this file, the pdf_* prefix refers to the PDF that contains the image
# we are adding to our document, prawn_* refers to the objects we are creating
# to be added to our prawn document.
class PrawnPDFImage < Prawn::Images::Image
  def self.can_render?(image_blob)
    image_blob.unpack('C5') == [37, 80, 68, 70, 45]
  end

  def initialize(image_blob)
    self.image_blob = image_blob
    self.reader = ::PDF::Reader.new StringIO.new(image_blob)
  end

  def build_pdf_object(document)
    self.document = document

    prawn_image_reference
  end

  private

  attr_accessor :image_blob, :reader, :document

  def pdf
    @pdf ||= PrawnPDFImage::PDF.new image_blob
  end

  def prawn_image_reference
    document.ref!(prawn_image_reference_options).tap do |ref|
      ref << pdf_image_data
      ref.data[:SMask] = prawn_soft_mask if pdf_soft_mask
    end
  end

  def prawn_image_reference_options
    {
      Type:             :XObject,
      Subtype:          :Image,
      ColorSpace:       pdf_image_colorspace,
      Height:           pdf_image_height,
      Width:            pdf_image_width,
      BitsPerComponent: pdf_image_bits_per_component,
      Filter:           pdf_image_filter,
      DecodeParms:      pdf_image_stream.hash[:DecodeParms]
    }
  end

  def prawn_soft_mask
    document.ref!(prawn_soft_mask_options).tap do |ref|
      ref.stream << pdf_soft_mask.data
    end
  end

  def prawn_soft_mask_options
    {
      Type:             :XObject,
      Subtype:          :Image,
      Width:            pdf_image_width,
      Height:           pdf_image_height,
      BitsPerComponent: pdf_image_bits_per_component,
      ColorSpace:       :DeviceGray,
      Filter:           pdf_soft_mask.hash[:Filter],
      DecodeParms:      pdf_soft_mask.hash[:DecodeParms]
    }
  end

  def pdf_soft_mask
    pdf_image_stream.hash[:SMask]
  end

  def pdf_image_filter
    pdf_image_stream.hash[:Filter]
  end

  def pdf_image_data
    pdf_image_stream.data
  end

  def pdf_image_colorspace
    cs = pdf_image_stream.hash[:ColorSpace]

    # Return if we are simply :DeviceRGB or DeviceCMYK
    return cs if cs.is_a? Symbol

    # We have an indexed ICCBased color profile, duplicate it.
    return indexed_colorspace if cs[0] == :Indexed

    # Hope this works as a fallback
    cs[1].hash[:Alternate]
  end

  def pdf_image_bits_per_component
    pdf_image_stream.hash[:BitsPerComponent]
  end

  def pdf_image_height
    pdf_image_stream.hash[:Height]
  end

  def pdf_image_width
    pdf_image_stream.hash[:Width]
  end

  def pdf_image_stream
    page.xobjects.first[1]
  end

  def page
    reader.page 1
  end

  # These methods are to conform to the API expected by Prawn Images and
  # are not used internally.
  attr_accessor :scaled_width, :scaled_height

  alias_method :width, :pdf_image_width
  alias_method :height, :pdf_image_height

  private

  def indexed_colorspace
    cs = pdf_image_stream.hash[:ColorSpace]

    document.ref!(
      [
        cs[0],
        indexed_colorspace_base,
        cs[2],
        indexed_colorspace_lookup
      ]
    )
  end

  def indexed_colorspace_base
    orig_stream = pdf_image_stream.hash[:ColorSpace][1]

    document.ref!(
      [
        orig_stream[0],
        indexed_colorspace_base_stream
      ]
    )
  end

  def indexed_colorspace_base_stream
    orig_stream = pdf_image_stream.hash[:ColorSpace][1][1]

    document.ref!(orig_stream.hash).tap do |ref|
      ref << orig_stream.data
    end
  end

  def indexed_colorspace_lookup
    orig_stream = pdf_image_stream.hash[:ColorSpace][3]

    document.ref!(orig_stream.hash).tap do |ref|
      ref << orig_stream.data
    end
  end
end

Prawn.image_handler.register PrawnPDFImage
