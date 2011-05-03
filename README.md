Askja
=====

Askja is a minimalist blogging platform written in Rails as a more flexible
alternative to static generators. Possibly it's most distinguishing feature is
that it requires articles to be defined in *.yml/*.md files, which can be
subsequently be loaded to the database to be served.

Askja is current themed by default for http://mutelight.org, the blog that it
was originally designed for, but this is the only way in which it's coupled to
a specific blog. Hopefully a generic theme will eventually be built.

Some major features:

* Similar article generation using LSI indexer
* Top article retrieval using Google analytics
* Full-page caching for extremely fast page loads

Installation
------------

### System Dependencies

The LSI indexer runs much faster with the GNU Scientific Library installed:

    brew install gsl
    pacman -S gsl

### Bundle Gems

Use bundler to prepare the application's Gem dependencies in its directory:

    bundle install --path .

### Secret Token

Copy `config/initializers/secret_token.rb.example` to `config/initializers/secret_token.rb`. Generate a new 512-bit token and store it in the new file. That's 128 hex [0-9a-f] characters.

### Load Schema

After configuring a production database, load the database schema with:

    rake db:schema:load RAILS_ENV=production

### Load Content

Content is stored in the `content/` subdirectory in Markdown/YAML format. If
you store your content in another Git repository, clone it out using something
like:

    git clone https://github.com/brandur/mutelight.git content

Run `rake init` whether or not custom content was checked out. This task will
generate the `content/` directory if it doesn't already exist.

Load content to the database using:

    rake update RAILS_ENV=production

Optionally, rank articles according to their views using:

    rake update:top RAILS_ENV=production

### Server

Askja should now be ready to go. Deploy it on Phusion Passenger or your 
favorite Rails server.

