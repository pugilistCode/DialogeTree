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
        text = "Great! Are you ready?",
        responses = {
            {text = "Yes, let's go!"},
            {text = "No, sorry"}
        }
    };

    QuestionC = {
        text = "Oh. Ok then"
    };
}