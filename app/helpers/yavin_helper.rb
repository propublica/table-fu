module YavinHelper
  def fmt(call, data)
    format = {
      :comma => lambda { |x| number_with_delimiter(x) },
      :percent => lambda { |x| number_to_percentage(x) },
      :currency => lambda { |x| number_to_currency(x) },
    }
    begin
      format[call.intern].call(data)
    rescue NoMethodError
      data
    end
  end
end
