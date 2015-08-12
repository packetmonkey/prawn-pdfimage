# prawn-pdfimage

Adds support for a [prawn](https://github.com/prawnpdf/prawn) to use
a PDF that contains an image as an image.


## Usage

**Gemfile**
```ruby
gem 'prawn-pdfimage'
```

**Your code**
```ruby
require 'prawn'
require 'prawn-pdfimage'

Prawn::Document.generate('output.pdf') do |pdf|
  pdf.image 'image.pdf'
end
```


## Limitations
The current code will add the first xobject on the first page as the image to
the Prawn document. For the common case (someone exporting an image as a PDF)
this works just fine. If you need more control over which object is inserted
into your Prawn document, PRs are welcome.


## Found a bug?
Open a [github issue](https://github.com/packetmonkey/prawn-pdfimage/issues)


## Contributing & Development
1. Fork the project.
2. Make your feature addition or bug fix. All specs should pass.
3. Add specs for your changes.
4. Commit
5. Send a pull request. Bonus points for topic branches.


## Licence
prawn-pdfimage is released under the [MIT Licence](http://choosealicense.com/licenses/mit/)


## Authors
prawn-pdfimage is written and maintained by Evan Sharp.
