RSpec.describe PrawnPDFImage do
  let(:file_path) { File.join __dir__, 'data', file_name }
  let(:document) { Prawn::Document.new }

  context 'with a transparent CMYK pdf image' do
    let(:file_name) { 'cmyk_transparent.pdf' }

    it 'creates the correct references' do
      expect(document).to receive(:ref!).with(
        Type: :XObject,
        Subtype: :Image,
        ColorSpace: :DeviceCMYK,
        Height: 50,
        Width: 50,
        BitsPerComponent: 8
      ).once.and_call_original

      expect(document).to receive(:ref!).with(
        Type: :XObject,
        Subtype: :Image,
        Width: 50,
        Height: 50,
        BitsPerComponent: 8,
        ColorSpace: :DeviceGray
      ).once.and_call_original

      document.image file_path
    end
  end

  context 'with an transparent RGB pdf image' do
    let(:file_name) { 'rgb_transparent.pdf' }

    it 'creates the correct references' do
      expect(document).to receive(:ref!).with(
        Type: :XObject,
        Subtype: :Image,
        ColorSpace: :DeviceRGB,
        Height: 40,
        Width: 40,
        BitsPerComponent: 8
      ).exactly(1).times.and_call_original

      expect(document).to receive(:ref!).with(
        Type: :XObject,
        Subtype: :Image,
        Width: 40,
        Height: 40,
        BitsPerComponent: 8,
        ColorSpace: :DeviceGray
      ).once.and_call_original

      document.image file_path
    end
  end

  context 'with an opaque RGB pdf image' do
    let(:file_name) { 'rgb_opaque.pdf' }

    it 'creates the correct reference' do
      expect(document).to receive(:ref!).with(
        Type: :XObject,
        Subtype: :Image,
        ColorSpace: :DeviceRGB,
        Height: 16,
        Width: 16,
        BitsPerComponent: 8
      ).exactly(1).times.and_call_original

      document.image file_path
    end
  end
end
