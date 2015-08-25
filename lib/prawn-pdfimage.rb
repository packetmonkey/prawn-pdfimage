require 'prawn'
require_relative 'prawn-pdfimage/pdf'

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
  end

  def build_pdf_object(document)
    self.document = document

    prawn_image_reference
  end

  private

  attr_accessor :image_blob, :document

  def pdf
    @pdf ||= PrawnPDFImage::PDF.new image_blob
  end

  def prawn_image_reference
    document.ref!(prawn_image_reference_options).tap do |ref|
      ref << pdf.image_data
      ref.data[:SMask] = prawn_soft_mask if pdf.soft_mask?
    end
  end

  def prawn_image_reference_options
    {
      Type:             :XObject,
      Subtype:          :Image,
      ColorSpace:       pdf_image_colorspace,
      Height:           pdf.image_height,
      Width:            pdf.image_width,
      BitsPerComponent: pdf.image_bits_per_component,
      Filter:           pdf.image_filter,
      DecodeParms:      pdf.image_decode_parms
    }
  end

  def prawn_soft_mask
    document.ref!(prawn_soft_mask_options).tap do |ref|
      ref.stream << pdf.soft_mask.data
    end
  end

  def prawn_soft_mask_options
    {
      Type:             :XObject,
      Subtype:          :Image,
      Width:            pdf.image_width,
      Height:           pdf.image_height,
      BitsPerComponent: pdf.image_bits_per_component,
      ColorSpace:       :DeviceGray,
      Filter:           pdf.soft_mask.hash[:Filter],
      DecodeParms:      pdf.soft_mask.hash[:DecodeParms]
    }
  end

  def pdf_image_colorspace
    cs = pdf.image_colorspace

    # Return if we are simply :DeviceRGB or DeviceCMYK
    return cs if cs.is_a? Symbol

    # We have an indexed ICCBased color profile, duplicate it.
    return indexed_colorspace if cs[0] == :Indexed

    # Hope this works as a fallback
    cs[1].hash[:Alternate]
  end

  # These methods are to conform to the API expected by Prawn Images and
  # are not used internally.
  attr_accessor :scaled_width, :scaled_height

  def height
    pdf.image_height
  end

  def width
    pdf.image_width
  end

  private

  def indexed_colorspace
    colorspace = pdf.image_colorspace

    document.ref!(
      [
        colorspace[0],
        indexed_colorspace_base,
        colorspace[2],
        indexed_colorspace_lookup
      ]
    )
  end

  def indexed_colorspace_base
    document.ref!(
      [
        pdf.indexed_colorspace_base[0],
        indexed_colorspace_base_stream
      ]
    )
  end

  def indexed_colorspace_base_stream
    document.ref!(pdf.indexed_colorspace_base[1].hash).tap do |ref|
      ref << pdf.indexed_colorspace_base[1].data
    end
  end

  def indexed_colorspace_lookup
    document.ref!(pdf.indexed_colorspace_lookup.hash).tap do |ref|
      ref << pdf.indexed_colorspace_lookup.data
    end
  end
end

Prawn.image_handler.register PrawnPDFImage
