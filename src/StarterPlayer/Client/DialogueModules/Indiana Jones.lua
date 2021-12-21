--[[
    skip = true
        If you're bringing the player back to a previous set of responses, skip the NPC's dialog animation - as they've just experienced it
]]

return {
    Config = {
        -- focusPart = "Head",
        prompt = "proximityPrompt" -- choose a prompt to initialize the conversation
    };

    Initialize = {
        text = "Hi, how are you?",
        responses = {
            {text = "Hey! I'm fine", nextQuestion = "QuestionB"},
            {text = "I'm doing great, thanks", nextQuestion = "QuestionB"},
            {text = "I don't care"},
        }
    };

    QuestionB = {
        text = "Great! What is it you want?",
        responses = {
            {text = "What is El Dorado?", nextQuestion = "QuestionC"},
            {text = "Goodbye"}
        }
    };

    QuestionC = {
        text = "El Dorado was the term used by the Spanish in the 16th century to describe a mythical tribal chief of the Muisca people",
        responses = {
            {text = "Cool, thanks!", nextQuestion = "QuestionB", skip = true},
            {text = "Goodbye", func = "startQuest"}
        };
    };
}