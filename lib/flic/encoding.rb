module Flic
  module Encoding
    def self.included(base)
      base.send(:attr_reader, :raw, :unpacked)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def opcode(arg = nil)
        arg ? (@opcode = arg) : @opcode
      end

      def packing(arg = nil)
        arg ?  (@packing = arg) : @packing
      end

      def mapping(arr = nil, setter = false)
        if arr
          @mapping = arr
          define_mapping_attrs(setter)
        else
          @mapping
        end
      end

      def mapped_index(name)
        (@mapping.index(name) || @mapping.find_index {|sname|
          next unless sname.is_a?(Array)
          sname.first == name
        }) + 2
      end

      def bdaddr_at(arg = nil)
        if arg
          @bdaddr_at = arg
          define_bdaddr_helper
        else
          @bdaddr_at
        end
      end

      def enums(set = nil)
        set ? (@enums = set) : @enums
      end

      private

      def define_mapping_attrs(setter)
        offset = 2
        method_body = ""
        mapping.each do |name|
          if name.is_a?(Array)
            name, length = name

            if length != :end
              method_body << <<-EOM
                def #{name}
                  unpacked[#{offset}..(#{offset + length - 1})]
                end
              EOM

              if setter
                method_body << <<-EOM
                def #{name}=(arg)
                  unless arg.is_a?(Array) && arg.length == #{length}
                    raise ArgumentError.new("Invalid args for: \#{name}, must be an array of length \#{length}")
                  end
                  arg.each_with_index do |item, index|
                    current = #{offset} + index
                    raw[current] = item
                  end
                end
                EOM
              end

              offset += (length)
            else
              method_body << <<-EOM
              def #{name}
                unpacked[#{offset}..-1]
              end
              EOM
            end
          else
            method_body << <<-EOM
              def #{name}
                unpacked[#{offset}]
              end
            EOM

            if setter
              method_body << <<-EOM
              def #{name}=(arg)
                unpacked[#{offset}] = arg
              end
              EOM
            end

            offset += 1
          end
        end
        class_eval(method_body, __FILE__, 51)
      end

      def define_bdaddr_helper
        alias_method(:"raw_#{@bdaddr_at}", @bdaddr_at)

        define_method(:"parsed_#{@bdaddr_at}") do
          Flic::BluetoothAddr.new(send(:"raw_#{self.class.bdaddr_at}"))
        end
        alias_method(@bdaddr_at, :"parsed_#{@bdaddr_at}")
      end
    end

    def initialize(arg)
      @raw = arg
    end

    def code_enums(arr)
      return arr unless self.class.enums
      self.class.enums.each do |index, enum|
        arr[index] = Enums.coded(enum, arr[index])
      end
      arr
    end

    def decode_enums(arr)
      return arr unless self.class.enums

      self.class.enums.each do |index, enum|
        arr[index] = Enums.decoded(enum, arr[index])
      end
      arr
    end

  end
end
