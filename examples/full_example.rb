#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailman'

Mailman::Application.run do
  default do 
  	# assume you have archive model for handle incoming mails
  	#example of archive model is below
  	Archive.archive_mail(message)

  end
end



# class Archive < ActiveRecord::Base

#     def self.archive_mail(message)
#         prepare_objects(message)

#         #creating directory to hold emails in public directory inside you app.
#         Dir.mkdir(@dir_name) unless Dir.exists?(@dir_name)
#         dir = Dir.new(@dir_name)

#         # storing the email in file with name of the email subject
#         email = File.open("#{@dir_name}/#{@file}","w")
#         email.write(@body.force_encoding("utf-8")) #take a look for other encodings if you deal with eastern languages  
#         email.close()
        
#         # store attachments in the same directory
#         self.handle_attachments
#     end


# 	  def self.prepare_objects(message)
#         if message.multipart?
#             @body = message.html_part.body.decoded
#         else
#             @body = message.body.decoded
#         end
#         @subject = message.subject
#         @attachments = message.attachments
#         @dir_name ="public/emails/"+@subject 	# path to store emails in 
#         @file = @subject + ".html"				# file contains the email body
#     end

#    	def self.handle_attachments 
#         if @attachments.any?
#             @attachments.each do |attach|
#                 next if attach.nil?
#                 uncomment the next line to get the content_type of each of the attachments
#         		# content_type =attach.content_type.split(";")[0]
#                 if attach.text?
#                      attachment_file = File.open("#{Rails.root}/public/emails/#{@subject}/#{attach.filename}","w+t")
#                      attachment_file.write(attach.body.to_s.force_encoding("utf-8"))
#                 else
#                 	# handle non text based files
#                     attachment_file = File.open("#{Rails.root}/public/emails/#{@subject}/#{attach.filename}", 'wb')
#                     attachment_file.write(attach.body.decoded)
#                 end
#                 attachment_file.close()
#             end
#         end
#     end
# end
