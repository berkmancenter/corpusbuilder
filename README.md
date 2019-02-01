# CorpusBuilder

## Dependencies

The development has been conducted in the environment as follows:

* Ruby 2.4.1p111
* Postgres 9.6.8 (TODO: check the lowest viable version given app usage of the database)

### External tools and libraries

* fribidi 0.3.6 (https://github.com/fribidi/fribidi/)
* tesserqact 4.0 (https://github.com/tesseract-ocr/tesseract)
* leptonica 1.74.2 (https://github.com/DanBloomberg/leptonica)
* libtiff

All above libraries can potentially be installed from the system's packages
with most likely exception of both `tesseract` and `leptonica`.

Ruby based dependencies are handled as usual via the Gemfile. Some gems may
require some external libraries, all of which should be easy to get as
system packages.

### Development time only

* Node (v8.6.0)
* Yarn (1.2.1)

All JavaScript related dependencies should be easy to get with just `yarn`.

## Environment variables

The app expects vertain environment variables set in order to operate properly:
```bash
CORPUSBUILDER_EXCEPTION_RECIPIENTS=iamanadmin@corpusbuilder.org
CORPUSBUILDER_HOST=http://corpusbuilder.org
CORPUSBUILDER_PORT=1234
```
## Integration

The app isn't meant to be used directly. It's purpose is to be both the database
of corpuses and the tools to work on them — all to be consumed by an external application.

This means that to use it, one needs to integrate it with some other, existing app.

For the Ruby-world, a helper integration gem has been provided:
https://github.com/berkmancenter/corpusbuilder-ruby-client

A more complete platform integration has been made with the SHARIAsource plaftorm. The
SHARIAsource platform is open-source software and can be found on github:
https://github.com/berkmancenter/SHARIAsource

## Contributors

CorpusBuilder was built with the collaborations of SHARIAsource and OpenITI.

## License

CorpusBuilder is licensed under the GNU AGPL 3.0 License.

## Copyright

2019 President and Fellows of Harvard College.
