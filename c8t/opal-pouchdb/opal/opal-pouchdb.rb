require 'opal'
class PouchDB
    def c args, prefix = nil
        params = "(#{args.map{|x| "\"#{x}\""}.join(", ")})"
        if prefix.nil?
            `self.pouch.params`
        else `#{prefix}#{params}`
        end
    end
    def initialize *args
        @pouch = c args, "new PouchDB" 
    end
    def self.metaclass; class << self; self; end; end
    def self.create_methods *arr
        arr.each do |a|
            metaclass.instance_eval do
                define_method a do |*args|
                    c args
                end
            end
        end
    end
    create_methods :destroy, :put, :get, :post, :remove, :bulkDocs, :allDocs, :changes
end
p "test"
db = PouchDB.new "blah"
p db
db.put({:_id => 'mydoc', :title => 'Heroes' }) do |err, resp|
    p err, resp
end
db.get 'Heroes' do |err, resp|
    p err, resp
end
