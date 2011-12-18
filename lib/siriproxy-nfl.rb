require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check tonight's NFL scores
# Example usage: "NFL Bears"
#############

class SiriProxy::Plugin::NFL < SiriProxy::Plugin

  @firstTeamName = ""
  @firstTeamScore = ""
  @secondTeamName = ""
  @secondTeamScore = ""
  @timeLeft = ""
  @teamInt = 0	
  @teamInt2 = 0
	def initialize(config)
    #if you have custom configuration options, process them here!
    end
  
  listen_for /NFL (.*)/i do |phrase|
	  team = pickOutTeam(phrase)
	  if team.include? "all games"
	  	allscores(team)
	  else
	  	score(team) #in the function, request_completed will be called when the thread is finished
	  end
	end
	
	def allscores(userTeam)
	  Thread.new {
	    doc = Nokogiri::HTML(open("http://m.espn.go.com/nfl/scoreboard"))
      	games = doc.css(".match")
      	games.each {
      		|game|
      		@timeLeft = game.css("span").first.content.strip
      		firstTeam = game.css(".competitor").first
      		secondTeam = game.css(".competitor").last
      		firstTemp = firstTeam.css("strong").first.content.strip
      		secondTemp = secondTeam.css("strong").first.content.strip
      		
      		@firstTeamName = firstTemp
      		@secondTeamName = secondTemp
      		@firstTeamScore = firstTeam.css("td").last.content.strip
			@secondTeamScore = secondTeam.css("td").last.content.strip

      		if @timeLeft.include? "Final"
        		response = "The Final score for the " + @firstTeamName + " game is: " + @firstTeamName + " (" + @firstTeamScore + "), " + @secondTeamName + " (" + @secondTeamScore + ")."
      		elsif @timeLeft.include? "PM"
        		response = "The " + @firstTeamName + " game is at " + @timeLeft + ". It will be the " + @firstTeamName + " vs " + @secondTeamName + "."
      		else
        		response = "The " + @firstTeamName + " are still playing. The score is " + @firstTeamName + " (" + @firstTeamScore + "), " + @secondTeamName + " (" + @secondTeamScore + ") with " + @timeLeft + "."
      		end
      			
      		say response
      		
      	  } 
			request_completed
		}
		
	  say "Checking all games for this week..."
	  
	end
	
	def score(userTeam)
	  Thread.new {
	    doc = Nokogiri::HTML(open("http://m.espn.go.com/nfl/scoreboard"))
      	games = doc.css(".match")
      	games.each {
      		|game|
      		@timeLeft = game.css("span").first.content.strip
      		firstTeam = game.css(".competitor").first
      		secondTeam = game.css(".competitor").last
      		firstTemp = firstTeam.css("strong").first.content.strip
      		secondTemp = secondTeam.css("strong").first.content.strip
      		#say "test-" + @teamInt + "-" + firstTemp + "-" + secondTemp + "-"
      		
      		#firstTemp = nameFromInt(firstTemp)
      		#secondTemp = nameFromInt(secondTemp)
      		
      		if firstTemp.include? userTeam
      			@firstTeamName = firstTemp
      			@secondTeamName = secondTemp
      			@firstTeamScore = firstTeam.css("td").last.content.strip
      			@secondTeamScore = secondTeam.css("td").last.content.strip
      			break
      		elsif secondTemp.include? userTeam
      			@firstTeamName = firstTemp
      			@secondTeamName = secondTemp
      			@firstTeamScore = firstTeam.css("td").last.content.strip
      			@secondTeamScore = secondTeam.css("td").last.content.strip
      			break
      		else
      			@firstTeamName = ""
      			@secondTeamName = ""
      		end
      			
      			
      		
      	} 
      	
      if((@firstTeamName == "") || (@secondTeamName == ""))
        response = "No games involving the " + userTeam + " were found playing tonight"
      elsif @timeLeft.include? "Final"
        	response = "The Final score for " + userTeam + " game is: " + @firstTeamName + " (" + @firstTeamScore + "), " + @secondTeamName + " (" + @secondTeamScore + ")."
      elsif @timeLeft.include? "PM"
        	response = "The " + userTeam + " game is at " + @timeLeft + ". It will be the " + @firstTeamName + " vs. " + @secondTeamName + "."
      else
        	response = "" + userTeam + " is still playing. The score is " + @firstTeamName + " (" + @firstTeamScore + "), " + @secondTeamName + " (" + @secondTeamScore + ") with " + @timeLeft + "."
      end
	  
			@firstTeamName = ""
			@secondTeamName = ""
			say response
			
			request_completed
		}
		
	  say "Checking to see if " + userTeam + " played today."
	  
	end

def nameFromInt(phrase)
    if(phrase.match(/BOS/i))
    	@teamInt = 1
      return "Celtics"
      end
    if(phrase.match(/NJN/i))
    @teamInt = 2
      return "Nets"
      end
    if(phrase.match(/NYK/i))
    @teamInt = 3
      return "Knicks"
      end
    if(phrase.match(/PHI/i))
    @teamInt = 4
      return "76ers"
      end
    if(phrase.match(/TOR/i))
    @teamInt = 5
      return "Raptors"
      end
    if(phrase.match(/CHI/i))
    @teamInt = 6
      return "Bulls"
      end
    if(phrase.match(/CLE/i))
    @teamInt = 7
      return "Cavaliers"
      end
    if(phrase.match(/DET/i))
    @teamInt = 8
      return "Pistons"
      end
    if(phrase.match(/IND/i))
    @teamInt = 9
      return "Pacers"
      end
    if(phrase.match(/MIL/i))
    @teamInt = 10
      return "Bucks"
      end
    if(phrase.match(/ATL/i) || phrase.match(/hawks/i))
    @teamInt = 11
      return "Hawks"
      end
    if(phrase.match(/CHA/i) || phrase.match(/bobcats/i))
    @teamInt = 12
      return "Bobcats"
      end
    if(phrase.match(/MIA/i) || phrase.match(/heat/i))
    @teamInt = 13
      return "Heat"
      end
    if(phrase.match(/ORL/i) || phrase.match(/magic/i))
    @teamInt = 14
      return "Magic"
      end
    if(phrase.match(/WAS/i) || phrase.match(/wizards/i))
    @teamInt = 15
      return "Wizards"
      end
    if(phrase.match(/GSW/i) || phrase.match(/warriors/i))
    @teamInt = 16
      return "Warriors"
      end
    if(phrase.match(/LAC/i) || phrase.match(/clippers/i))
    @teamInt = 17
      return "Clippers"
      end
    if(phrase.match(/LAL/i) || phrase.match(/lakers/i))
    @teamInt = 18
      return "Lakers"
      end
    if(phrase.match(/PHX/i) || phrase.match(/phoenix/i))
    @teamInt = 19
      return "Suns"
      end
    if(phrase.match(/SAC/i) || phrase.match(/kings/i))
    @teamInt = 20
      return "Kings"
      end
    if(phrase.match(/DAL/i) || phrase.match(/mavericks/i))
    @teamInt = 21
      return "Mavericks"
      end
    if(phrase.match(/HOU/i) || phrase.match(/rockets/i))
    @teamInt = 22
      return "Rockets"
      end
    if(phrase.match(/MEM/i) || phrase.match(/grizzles/i))
    @teamInt = 23
    return "Grizzles"
    end
    if(phrase.match(/NOR/i) || phrase.match(/hornets/i))
    @teamInt = 24
      return "Hornets"
      end
    if(phrase.match(/SAS/i) || phrase.match(/spurs/i))
    @teamInt = 25
      return "Spurs"
      end
    if(phrase.match(/DEN/i) || phrase.match(/nuggets/i))
    @teamInt = 26
      return "Nuggets"
      end
    if(phrase.match(/MIN/i) || phrase.match(/timberwolves/i))
    @teamInt = 27
      return "Timberwolves"
      end
    if(phrase.match(/OKC/i) || phrase.match(/thunder/i))
    @teamInt = 28
      return "Thunder"
      end
    if(phrase.match(/POR/i) || phrase.match(/trailblazers/i))
    @teamInt = 29
      return "Trailblazers"
      end
    if(phrase.match(/UTH/i) || phrase.match(/jazz/i))
    @teamInt = 30
      return "Jazz"
      end
	
		return phrase
	
	end

	
  def pickOutTeam(phrase)
    if(phrase.match(/Jacksonville/i) || phrase.match(/Jaguars/i))
    	@teamInt2 = 1
      return "Jacksonville"
      end
    if(phrase.match(/Atlanta/i) || phrase.match(/falcons/i))
    @teamInt2 = 2
      return "Atlanta"
      end
    if(phrase.match(/Dallas/i) || phrase.match(/cowboys/i))
    @teamInt2 = 3
      return "Dallas"
      end
    if(phrase.match(/Tampa Bay/i) || phrase.match(/Buccaneers/i))
    @teamInt2 = 4
      return "Tampa Bay"
      end
    if(phrase.match(/Miami/i) || phrase.match(/dolphins/i))
    @teamInt2 = 5
      return "Miami"
      end
    if(phrase.match(/Buffalo/i) || phrase.match(/bills/i))
    @teamInt2 = 6
      return "Buffalo"
      end
    if(phrase.match(/Seattle/i) || phrase.match(/seahawks/i))
    @teamInt2 = 7
      return "Seattle"
      end
    if(phrase.match(/green bay/i) || phrase.match(/packers/i))
    @teamInt2 = 8
      return "Green Bay"
      end
    if(phrase.match(/kansas city/i) || phrase.match(/chiefs/i))
    @teamInt2 = 9
      return "Kansas City"
      end
    if(phrase.match(/Tennessee/i) || phrase.match(/titans/i))
    @teamInt2 = 10
      return "Tennessee"
      end
    if(phrase.match(/Chicago/i) || phrase.match(/bears/i))
    @teamInt2 = 11
      return "Chicago"
      end
    if(phrase.match(/Indianapolis/i) || phrase.match(/colts/i))
    @teamInt2 = 12
      return "Indianapolis"
      end
    if(phrase.match(/New Orleans/i) || phrase.match(/saints/i))
    @teamInt2 = 13
      return "New Orleans"
      end
    if(phrase.match(/Minnesota/i) || phrase.match(/vikings/i))
    @teamInt2 = 14
      return "Minnesota"
      end
    if(phrase.match(/Cincinnati/i) || phrase.match(/bengals/i))
    @teamInt2 = 15
      return "Cincinnati"
      end
    if(phrase.match(/St. Louis/i) || phrase.match(/rams/i))
    @teamInt2 = 16
      return "St. Louis"
      end
    if(phrase.match(/Washington/i) || phrase.match(/redskins/i))
    @teamInt2 = 17
      return "Washington"
      end
    if(phrase.match(/New York Giants/i) || phrase.match(/giants/i))
    @teamInt2 = 18
      return "New York Giants"
      end
    if(phrase.match(/Carolina/i) || phrase.match(/panthers/i))
    @teamInt2 = 19
      return "Carolina"
      end
    if(phrase.match(/Houston/i) || phrase.match(/texans/i))
    @teamInt2 = 20
      return "Houston"
      end
    if(phrase.match(/Detroit/i) || phrase.match(/lions/i))
    @teamInt2 = 21
      return "Detroit"
      end
    if(phrase.match(/oakland/i) || phrase.match(/raiders/i))
    @teamInt2 = 22
      return "Oakland"
      end
    if(phrase.match(/new england/i) || phrase.match(/patriots/i))
    @teamInt2 = 23
    return "New England"
    end
    if(phrase.match(/New York Jets/i) || phrase.match(/jets/i))
    @teamInt2 = 24
      return "New York Jets"
      end
    if(phrase.match(/Philadelphia/i) || phrase.match(/eagles/i))
    @teamInt2 = 25
      return "Philadelphia"
      end
    if(phrase.match(/Cleveland/i) || phrase.match(/browns/i))
    @teamInt2 = 26
      return "Cleveland"
      end
    if(phrase.match(/Arizona/i) || phrase.match(/cardinals/i))
    @teamInt2 = 27
      return "Arizona"
      end
    if(phrase.match(/Baltimore/i) || phrase.match(/ravens/i))
    @teamInt2 = 28
      return "Baltimore"
      end
    if(phrase.match(/San Diego/i) || phrase.match(/chargers/i))
    @teamInt2 = 29
      return "San Diego"
      end
    if(phrase.match(/Pittsburgh/i) || phrase.match(/steelers/i))
    @teamInt2 = 30
      return "Pittsburgh"
      end
    if(phrase.match(/denver/i) || phrase.match(/broncos/i))
    @teamInt2 = 29
      return "Denver"
      end
    if(phrase.match(/San Francisco/i) || phrase.match(/49ers/i))
    @teamInt2 = 30
      return "San Francisco"
      end
	
		return phrase
	
	end
end
