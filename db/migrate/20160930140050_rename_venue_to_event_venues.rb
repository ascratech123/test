class RenameVenueToEventVenues < ActiveRecord::Migration
  def change
  	rename_table :venues, :event_venues
  end
end
