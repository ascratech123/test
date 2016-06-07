require 'rubygems'
require 'roo'
require 'open-uri'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportMyTravel
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    attributes = MyTravel.column_names
    attributes -= ["id","created_at", "updated_at"]
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportMyTravel.validate_objekts(objekts)
    if errors.blank?
      ExcelImportMyTravel.save_objekts(objekts)
      return {:is_saved => true}
    else
      excel_errors = "Errors found at rows: #{errors.to_sentence}"
      return {:is_saved => false, :excel_errors => excel_errors}
    end
  end

  def self.update(file_path, klass_name, attributes=[], operation='add', options={})
    objekts = self.prepare_objekts(file_path, klass_name, attributes, operation, options)
    return {:is_saved => true}
  end

  def self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    # ENV['ROO_TMP'] = "#{Rails.root}/tmp"
    ext = File.extname(file_path)
    puts ext
    workbook = nil
    if File.extname(file_path) == ".xlsx"
      workbook = Roo::Excelx.new(file_path)
    elsif File.extname(file_path) == ".xls"
      workbook = Roo::Excel.new(file_path)
    end
   start_row = options[:start_row] || 1
   objekts = []
   columns_in_worksheet = []
   workbook.default_sheet = workbook.sheets.first
   0.upto(workbook.last_column) do |col|
     columns_in_worksheet << workbook.cell(workbook.first_row, col)
   end
   columns_in_worksheet.compact!
   letters_array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z","AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ"]
    start_row.upto(workbook.last_row) do |line|
      objekt = nil
      objekt = {} #klass_name.classify.constantize.new()
      columns_in_worksheet.each_with_index do |attrib, index|
        objekt[attrib.parameterize('_').strip] = workbook.cell(line, letters_array[index]).strip rescue ''
      end
      event = Event.find_by_id(event_id)
      invitee_id = event.invitees.find_by_email(objekt["invitee_email"]).id rescue nil
      url = objekt["pdf_url"] rescue nil
      data = open(url).read
      write_file_content = File.open("public/#{url.split("/").last.split("-").last.split("?").first}", 'wb') do |f|
        f.write(data)
      end
      attach_file = (File.open("public/#{url.split("/").last.split("-").last.split("?").first}",'rb'))
      my_travel = MyTravel.find_or_initialize_by(:event_id => event_id,:invitee_id => invitee_id)
      my_travel.attach_file = attach_file
      objekts << my_travel
      File.delete("public/#{url.split("/").last.split("-").last.split("?").first}") if File.exist?("public/#{url.split("/").last.split("-").last.split("?").first}")
    end
    objekts.compact
  end

  def self.validate_objekts(objekts)
    error_rows = []
    objekts.each_with_index do |objekt, index|
      if objekt.invalid?
        error_message = objekt.errors.full_messages.join(", ")
        error_message = "receiver not present in panel or speaker" if error_message == "Receiver can't be blank"
        error_rows << "row#{index + 2} :   #{error_message}\n"
      end  
      Rails.logger.info objekt.errors.inspect
    end
    error_rows
  end

  def self.save_objekts(objekts)
    objekts.each do |objekt|
      objekt.save
    end
  end

end