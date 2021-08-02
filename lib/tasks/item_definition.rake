namespace :item_definition do
  task :create_yaml do
    require "csv"

    hash = {}
    CSV.read(Rails.root.join('db', 'terraria_items.csv')).each do |row|
      hash[row[0]] = { name: row[1], internal_name: row[2] }
    end
    File.open(Rails.root.join('item_definitions.yml'), 'w') { |f| f.write(hash.to_yaml) }
  end
end
