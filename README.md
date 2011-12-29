Askja
=====

Askja is a minimalist blogging platform written in Rails as a more flexible
alternative to static generators. Possibly it's most distinguishing feature is
that it requires articles to be defined in `*.yml`/`*.md` files, which can be
subsequently be loaded to the database to be served.

Askja is current themed by default for http://mutelight.org, the blog that it
was originally designed for, but this is the only way in which it's coupled to
a specific blog. Hopefully a generic theme will eventually be built.

Some major features:

* Top article retrieval using Google analytics
* Full-page caching for extremely fast page loads

Installation
------------

### Bundle Gems

Use bundler to prepare the application's Gem dependencies in its directory:

    bundle install

### Configuration

Copy `config/config.yml.example` to `config/config.yml` and modify its values as appropriate.

### Secret Token

Deploy a new secret token with:

    rake secret_deploy

### Load Schema

After configuring a production database, load the database schema with:

    rake db:schema:load RAILS_ENV=production

### Load Content

Content is stored in the `content/` subdirectory in Markdown/YAML format. If
you store your content in another Git repository, clone it out using something
like:

    git clone https://github.com/brandur/mutelight.git content

Run the `init` task whether or not custom content was checked out. This task
will generate the `content/` directory if it doesn't already exist.

    rake init

Load content to the database using:

    rake update RAILS_ENV=production

Optionally, rank articles according to their views using:

    rake update:top RAILS_ENV=production

### Server

Askja should now be ready to go. Deploy it on Phusion Passenger or your 
favorite Rails server.

Troubleshooting
---------------

### Content images don't load

`rake:init` creates a symlink from `public/images/articles/` back to the
`content/images` directory. Nginx with Phusion Passenger for example, doesn't
follow this symlink properly. A bind works instead (requires root access):

    sudo mount --bind $(pwd)/content/images $(pwd)/public/images/articles

This can be placed in `/etc/fstab` like so:

    <src> <dest> none defaults,bind 0 0
