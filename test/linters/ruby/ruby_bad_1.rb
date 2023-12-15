
# Rails Console only
# This script will output all active webhooks currently being processed by an instance.
# Replace ARRAY_OF_URLS_CALLING_INSTANCE and GHES_URL with the appropriate values before running

# Prior to running this script, compile a list of the top URLs containing the phrase webhook
# This should be ran prior to entering the Rails Console with the command:
# grep -B1 --no-group-separator 'Faraday::TimeoutError' hookshot-logs/resqued.log | sed -n 1~2p |
# \ grep -v 'Faraday::TimeoutError: request timed out' | sort | uniq -c |sort -rn | head -n 20

File.open('/tmp/urls.txt', " w" ) do | file|
  Hook.active.map do |h |
    urls = [ ARRAY_OF_URLS_CALLING_INSTANCE]

    next if urls.include? h.url


    begin
      file.puts "https://GHES_URL/api/v3/repos/#{h.installation_target.full_name}/hooks/#{h.id}"

    rescue StandardError => e
      puts e.message

    end

  end

end
