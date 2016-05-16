require 'rest_client'
require 'open-uri'


drink = ask "", {
  choices: '[ANY]'
}

url = "http://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{URI::encode(drink.value)}"
log "Drink URL ====> #{url}"
drank = JSON.parse(RestClient.get url)
log "Drink details ====> #{drank}"

if drank['drinks'].nil?
  url = "http://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{drink.value}"
  drank = JSON.parse(RestClient.get url)

  drank['drinks'].each do |d|
    url = "http://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{d['idDrink']}"
    new_drink = JSON.parse(RestClient.get url)
    text = get_detail(new_drink)
    drank(text) if $currentCall.isActive
  end

  hangup
else
  read_data(drank)
end

if $currentCall.isActive
  say 'There are no more entries'
  hangup
end


def get_detail(drank)
  text = "\u{1f379}#{drank['strDrink']}\u{1f379}:\n "
  for i in 1..15
    break if drank["strMeasure#{i}"] == " " || drank["strMeasure#{i}"] == "" || drank["strMeasure#{i}"] == "\n" || drank["strMeasure#{i}"] == nil
    text = "#{text}#{drank["strMeasure#{i}"]} of #{drank["strIngredient#{i}"]}, "
  end

  text = text[0..text.length-3]
  text = "#{text} - #{drank["strInstructions"]}"
end

def read_data(drank)
  drank['drinks'].each do |d|
    text = get_detail(d)
    if text.length / 130 == 0
      say text
    else
      text = text.scan(/.{1,130}/)
      text.each do |t|
        say t
        wait 3000
      end

    end
    response = ask "Would you like to see the next drink or are you happy with this one?", {
      choices: 'yes(yes, Yes, YES, y, Y, yea, yup, yeah, Yea, Yup, Yeah), no(no, No, NO, Nope, nope, nah, n, N, Nah)',
      timeout: 3600
    }
    if response.value.downcase == 'yes'
      say 'Great, thank you and have a great day!'
      hangup
      break
    elsif response.value.downcase == 'no'
      say 'Okay, grabbing the next entry'
    else
      say 'I did not understand that response. Goodbye'
      hangup
      break
    end
  end
end
