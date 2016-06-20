class Grouping < ActiveRecord::Base
  resourcify
  OPERATOR_SIGN = {"Greater than" => '>', "Greater than equal to" => '>=', "Less than" => '<', "Less than equal to" => '<=', "Equal to" => 'IN', "Not equal" => 'NOT IN', 'Contains' => 'like', 'Not contains' => 'not like', 'Starts with' => 'like',  'Ends with' => 'like','In' => '=', 'Between Two Numbers' => 'IN'}
  attr_accessor :value, :validation, :options
  serialize :condition, Hash
  
  belongs_to :event

  #attr_accessor :attr1_value, :attr2_value, :attr3_value, :attr4_value, :attr5_value, :attr6_value, :attr7_value, :attr8_value, :attr9_value, :attr10_value, :attr11_value, :attr12_value, :attr13_value, :attr14_value, :attr15_value
  #attr_accessor :attr1_validation, :attr2_validation, :attr3_validation, :attr4_validation, :attr5_validation, :attr6_validation, :attr7_validation, :attr8_validation, :attr9_validation, :attr10_validation, :attr11_validation, :attr12_validation, :attr13_validation, :attr14_validation, :attr15_validation
  #attr_accessor :attr1_options, :attr2_options, :attr3_options, :attr4_options, :attr5_options, :attr6_options, :attr7_options, :attr8_options, :attr9_options, :attr10_options, :attr11_options, :attr12_options, :attr13_options, :attr14_options, :attr15_options
  validates :name, presence: { :message => "This field is required." }
  default_scope { order('created_at desc') }

  # def self.default_validation
  #   ["Greater than", "Greater than equal to", "Less than", "Less than equal to", "Equal to", "Not equal", 'Contains', 'Not contains', 'Starts with', 'Ends with']#, 'In', 'Between']
  # end 


  def self.default_validation
    ["Equal to", "Not equal", 'Starts with', 'Ends with', 'Contains', 'Greater than equal to', 'Less than equal to', 'Between Two Numbers']
  end

  def self.get_query_value(c, v)
    case c
    when 'Contains'
      "#{v}".split(",").map{|v|v.strip && '%'+v.strip+"%"}
    when 'Not contains'
      # "%#{v}%".split(',')
      "#{v}".split(",").map{|v|v.strip && "%"+v.strip+"%"}
    when 'Between Two Numbers'
      f = "#{v}".split(",").map{|v|v.strip}.first rescue 0
      l = "#{v}".split(",").map{|v|v.strip}.last rescue 1000
      f..l
    when 'Greater than equal to'
      "#{v}".to_i rescue 0
    when 'Less than equal to'
      "#{v}".to_i rescue 0
    when 'Starts with'
      # "#{v}%".split(',')
      "#{v}".split(",").map{|v|v.strip && v.strip+"%"}
    when 'Ends with'
      # "%#{v}".split(',')
      "#{v}".split(",").map{|v|v.strip && "%"+v.strip}
    when 'Equal to'
      "#{v}".split(',').map{|v|v.strip}
    else
      "#{v}"
    end
  end

  def self.get_query_condition(c)
    OPERATOR_SIGN[c]
  end

  def self.get_default_grouping_fields(event)
    arr = event.invitee_structures.first.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier').map{|st| st[1].to_s.length > 0 ? st : nil}
    if arr.include?nil
      arr.compact!
    else
      arr
    end
  end

  def get_search_data_count(invitee_data)
    conditions = []
    self.condition.map{|condition| condition[1]['value'].present? ? conditions << condition : nil}
    if conditions.present? and invitee_data.present?
      conditions.each do |condition|
        k = condition[0] 
        c = Grouping.get_query_condition(condition[1]['condition'])
        v = Grouping.get_query_value(condition[1]['condition'], condition[1]['value'])
        if c == "like"
          invitee_data1 = []
          v.each do |value|
            invitee_data1 += invitee_data.where("#{k} #{c} (?)", value)
          end
          invitee_data = invitee_data1 
        else
          invitee_data = invitee_data.where("#{k} #{c} (?)", v)
        end
      end
    end
    invitee_data.present? ? invitee_data : []
  end

  def self.get_search_data_count(invitee_data, groupings)
    conditions = []
    invitee_data_ids = []
    if groupings.present?
      if groupings.map{|g| g.name}.include? "Default Group"
        invitee_data = invitee_data
      else
        groupings.each do |grouping|
          grouping.condition.map{|condition| condition[1]['value'].present? ? conditions << condition : nil}
          if conditions.present? and invitee_data.present?
            conditions.each do |condition|
              k = condition[0] 
              c = Grouping.get_query_condition(condition[1]['condition'])
              v = Grouping.get_query_value(condition[1]['condition'], condition[1]['value'])
              if c == "like"
                v.each do |value|
                  invitee_data_ids += invitee_data.where("#{k} #{c} (?)", value)
                end 
              else
                invitee_data = invitee_data.where("#{k} #{c} (?)", v)
                invitee_data_ids += invitee_data.pluck(:id)
              end
            end
          else
            invitee_data_ids += invitee_data.pluck(:id)
          end
        end
        invitee_data_ids = invitee_data_ids.compact.uniq
        invitee_data = invitee_data.where(:id => invitee_data_ids) rescue []
      end
      invitee_data.present? ? invitee_data : []
    else
      []
    end
  end

end