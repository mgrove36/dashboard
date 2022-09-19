#"aCnPi-aKBsH-ALNWZ-zfAiz-SQYdK"
require "active_support"
require "builder"
require "net/https"
require "rexml/document"
require "rexml/xpath"
require "icalendar"
require "net-http-report"
require "time"

@user="usr"
@password="pwd"
NAMESPACES = { "xmlns:d" => 'DAV:', "xmlns:c" => "urn:ietf:params:xml:ns:caldav" }
@calendars = ["cal_link_1", "cal_link_2"]

@startTime=Time.now
@endTime=@startTime.next_month(1)

def  errorhandling response   
	#raise AuthenticationError if response.code.to_i == 401
	#raise NotExistError if response.code.to_i == 410 
	#raise APIError if response.code.to_i >= 500
end

class ReportVEVENT
    attr_accessor :tstart, :tend
    attr :xml

    def initialize( tstart=nil, tend=nil )
        @tstart = tstart
        @tend   = tend
        @xml = Builder::XmlMarkup.new(:indent => 2)
        @xml.instruct!
    end

    def to_xml
        xml.c 'calendar-query'.intern, NAMESPACES do
            xml.d :prop do
                xml.d :getetag
                xml.c 'calendar-data'.intern
            end
            xml.c :filter do
                xml.c 'comp-filter'.intern, :name=> 'VCALENDAR' do
                    xml.c 'comp-filter'.intern, :name=> 'VEVENT' do
                        xml.c 'time-range'.intern, :start=> "#{tstart}Z", :end=> "#{tend}Z"
                    end
                end
            end
        end
    end
end 

def __create_http url
	uri = URI(url)
	@host = uri.host
	@port = uri.port.to_i
	@url = uri.path
	http = Net::HTTP.new(@host, @port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	http
end

def find_events
	@events = []
	@yaml_events = 'events:
'
	@calendars.each do |calendar_url|
		result = ""
		events = []
		res = nil
		__create_http(calendar_url).start { |http|
			req = Net::HTTP::Report.new(calendar_url, initheader = {'Content-Type'=>'application/xml','Depth'=>'1'} )
        
			req.basic_auth @user, @password
			req.body = ReportVEVENT.new(@startTime.utc.strftime("%Y%m%dT%H%M%S"), @endTime.utc.strftime("%Y%m%dT%H%M%S") ).to_xml
			res = http.request(req)
		}
		errorhandling res
		result = ""
		xml = REXML::Document.new(res.body)
		REXML::XPath.each( xml, '//c:calendar-data/', {"c"=>"urn:ietf:params:xml:ns:caldav"} ){|c| result << c.text}
		r = Icalendar::Calendar.parse(result)      
		unless r.empty?
			r.each do |calendar|
				calendar.events.each do |event|
					@events << event
					@yaml_events << '  - name: >-
      ' + event.summary + '
    date: ' + event.dtstart.to_s + '
    background: "lightblue"
'
puts event.rrule
				end
			end
		end
	end
	if @events.empty?
		return false
	end
end

find_events

puts @yaml_events
File.write('/home/me/dashboard/timeline.yml', @yaml_events)

