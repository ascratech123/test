require 'rubygems'
require 'roo'
# require 'zip/zipfilesystem'
#include ActiveSupport::Inflector

module ExcelImportInviteeData
#options => {:start_row => 'start_row_number'}
  def self.save(file_path, klass_name, event_id,attributes=[], operation='add', options={})
    event = Event.find(event_id)
    event_structure = event.invitee_structures.first
    attributes = event_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','email_field').map{|k, v| v.to_s.length > 0 ? v : nil}.compact
    objekts = self.prepare_objekts(file_path, klass_name, event_id, attributes, operation, options)
    errors = ExcelImportInviteeData.validate_objekts(objekts)
    if errors.blank?
      ExcelImportInviteeData.save_objekts(objekts[0])
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
   column_match_errors = nil
   workbook.default_sheet = workbook.sheets.first
   0.upto(workbook.last_column) do |col|
     columns_in_worksheet << workbook.cell(workbook.first_row, col)
   end
   columns_in_worksheet = columns_in_worksheet.compact
   letters_array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z","AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ"]
    start_row.upto(workbook.last_row) do |line|
      objekt = nil
      objekt = {} #klass_name.classify.constantize.new()
      columns_in_worksheet.each_with_index do |attrib, index|
        if workbook.cell(line, letters_array[index]).present?
          set_value = workbook.cell(line, letters_array[index]).is_a?(Numeric) ? workbook.cell(line, letters_array[index]).ceil.to_s : workbook.cell(line, letters_array[index]).strip
          objekt[attrib.parameterize('_').strip.downcase] = set_value rescue ''
        end
      end
      arr = attributes.zip(columns_in_worksheet).map{ |x, y| x.to_s.strip.downcase == y.to_s.strip.downcase }
      column_match_errors = arr.include? false
      event = Event.find(event_id)
      invitee_structure = event.invitee_structures.first
      identifier_key = invitee_structure.attributes[invitee_structure.uniq_identifier].downcase
      identifier_value = objekt[identifier_key]
      invitee_data = InviteeDatum.find_or_initialize_by(invitee_structure.uniq_identifier => objekt[identifier_key.gsub(' ', '_')], :invitee_structure_id => invitee_structure.id)
      invitee_data.skip_status_update = "true"
      invitee_hsh = {}
      object_attributes = invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier').map{|k, v| v.to_s.length > 0 ? [k, v.parameterize('_').strip.downcase] : nil}.compact
      object_attributes.each do |object_attribute|
        invitee_hsh[object_attribute[0]] = objekt[object_attribute[1].downcase].to_s rescue ""
      end
      invitee_data.assign_attributes(invitee_hsh)
      objekts << invitee_data
    end
    [objekts.compact, column_match_errors]
  end

  def self.validate_objekts(objekts)
    error_rows = []
    if objekts[1] == false
      objekts[0].each_with_index do |objekt, index|
        error_rows << "row#{index + 2} :   #{objekt.errors.full_messages.join(", ")}\n" if objekt.invalid?
        Rails.logger.info objekt.errors.inspect
      end
    else
      error_rows << "row#{1} :  Columns Does not match"
    end
    error_rows
  end

  def self.save_objekts(objekts)
    objekts.each do |objekt|
      objekt.save
    end
  end

end