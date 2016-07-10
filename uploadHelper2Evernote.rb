#####
# Before running this sample, you must:
# - fill in your Evernote developer token and rewrite parameters of settings.
# - install evernote-thrift gem.
# for Evernote API
require "digest/md5"
require 'evernote-thrift'

#################################################
# Settings
#
# get pdf filename which are located at local directory.
#
ext = ".pdf"

# Create a new note
tagname = [".scandata", ".book"]
file_mime = "application/pdf"

# specify a index of notebooks (ex. 0, 1, ....)
#notebookid=4

# enable to find in sub-directories.
def create_filename_list (param)
  ar = []
  Dir::glob(param){|f|
    next unless FileTest.file?(f)
    ar << f
  }
  return ar
end

################################################
# set Evernote environment

# Real applications authenticate with Evernote using OAuth, but for the
# purpose of exploring the API, you can get a developer token that allows
# you to access your own Evernote account. To get a developer token, visit
# https://sandbox.evernote.com/api/DeveloperToken.action
authToken = "your developer token"

if authToken == "your developer token"
  puts "Please fill in your developer token"
  puts "To get a developer token, visit https://sandbox.evernote.com/api/DeveloperToken.action"
  exit(1)
end

# Initial development is performed on our sandbox server. To use the production
# service, change "sandbox.evernote.com" to "www.evernote.com" and replace your
# developer token above with a token from
# https://www.evernote.com/api/DeveloperToken.action
evernoteHost = "sandbox.evernote.com"
#evernoteHost = "www.evernote.com"
userStoreUrl = "https://#{evernoteHost}/edam/user"

userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)

versionOK = userStore.checkVersion("Evernote EDAMTest (Ruby)",
				   Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
				   Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
puts "Is my Evernote API version up to date?  #{versionOK}"
puts
exit(1) unless versionOK


# Get the URL used to interact with the contents of the user's account
# When your application authenticates using OAuth, the NoteStore URL will
# be returned along with the auth token in the final OAuth request.
# In that case, you don't need to make this call.
noteStoreUrl = userStore.getNoteStoreUrl(authToken)


noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

# List all of the notebooks in the user's account
notebooks = noteStore.listNotebooks(authToken)

puts "Found #{notebooks.size} notebooks:"

#defaultNotebook = notebooks.fetch(notebookid)

#notebooks.each do |notebook|
#  puts "  * #{notebook.name}"
#end

#puts
#puts "Creating a new note in the default notebook: #{defaultNotebook.name}"
#puts


####
# make a list by searching *.ext
# get current directory

location = Dir::pwd

# pick up files
param_of_search = location + "/**/*" + ext
filelist = create_filename_list param_of_search

# upload each file to Evernote
filelist.each { |f|

  ###
  # get a title name from each file name.
  # ex.) aaa.pdf  -> take the string "aaa".
  # Set Evernote Notebook Info.
  title = File.basename(f, ext)
  p title + " and " +  f

  note = Evernote::EDAM::Type::Note.new
  note.title = title
  note.tagNames = tagname
  filename = f
  image = File.open(filename, "rb") { |io| io.read }
  hashFunc = Digest::MD5.new

  data = Evernote::EDAM::Type::Data.new
  data.size = image.size
  data.bodyHash = hashFunc.digest(image)
  data.body = image

  resource = Evernote::EDAM::Type::Resource.new
  resource.mime = file_mime
  resource.data = data
  resource.attributes = Evernote::EDAM::Type::ResourceAttributes.new
  resource.attributes.fileName = title

  # Now, add the new Resource to the note's list of resources
  note.resources = [ resource ]

  # To display the Resource as part of the note's content, include an <en-media>
  # tag in the note's ENML content. The en-media tag identifies the corresponding
  # Resource using the MD5 hash.
  hashHex = hashFunc.hexdigest(image)

  # The content of an Evernote note is represented using Evernote Markup Language
  # (ENML). The full ENML specification can be found in the Evernote API Overview
  # at http://dev.evernote.com/documentation/cloud/chapters/ENML.php
  note.content = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>Here is the uploaded PDF by scripting : "#{title}"<br/>
  <en-media type="#{file_mime}" hash="#{hashHex}"/>
</en-note>
EOF

  # Finally, send the new note to Evernote using the createNote method
  # The new Note object that is returned will contain server-generated
  # attributes such as the new note's unique GUID.
  createdNote = noteStore.createNote(authToken, note)

  puts "Successfully created a new note with GUID: #{createdNote.guid}"
  
}

exit
