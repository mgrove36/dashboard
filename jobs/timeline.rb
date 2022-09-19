require 'yaml'

MAX_DAYS_OVERDUE = -20
MAX_DAYS_AWAY = 90

config_file = '/home/me/dashboard/timeline.yml'

SCHEDULER.every '6h', :first_in => 0 do |job|
  config = YAML.load_file(config_file)
  unless config["events"].nil?
    events =  Array.new
    today = Date.today
    no_event_today = true
    config["events"].each do |event|
      days_away = (event["date"] - today).to_i
      if (days_away >= 0) && (days_away <= MAX_DAYS_AWAY) 
        events << {
          name: event["name"],
          date: event["date"],
          background: event["background"]
        }
      elsif (days_away < 0) && (days_away >= MAX_DAYS_OVERDUE)
        events << {
          name: event["name"],
          date: event["date"],
          background: event["background"],
          opacity: 0.5
        }
      end

      no_event_today = false if days_away == 0
    end

    if no_event_today
      events << {
        name: "TODAY",
        date: today.strftime('%a %d %b %Y'),
        background: "gold"
      }
    end
    File.write("/home/me/dashboard/timeline.log", "events sorted...\n" + events.to_s)
    send_event("a_timeline", {events: events})
  else
    puts "No events found :("
  end
end
