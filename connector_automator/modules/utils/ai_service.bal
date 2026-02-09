import ballerina/ai;
import ballerina/log;
import ballerinax/ai.anthropic;

ai:ModelProvider? anthropicModel = ();
configurable string apiKey = ?;

public function initAIService(boolean quietMode = false) returns error? {
    // Alternative if the constant doesn't exist:
    ai:ModelProvider|error modelProvider = new anthropic:ModelProvider(
        apiKey,
        "claude-opus-4-5-20251101",  // Direct string
        maxTokens = 64000,
        timeout = 400
    );
    if modelProvider is error {
        return error("Failed to initialize model provider", modelProvider);
    }
    anthropicModel = modelProvider;

    if !quietMode {
        log:printInfo("LLM service initialized successfully");
    }
}

public function callAI(string prompt) returns string|error {
    ai:ModelProvider? model = anthropicModel;
    if model is () {
        return error("AI model not initialized. Please call initAIService() first.");
    }

    ai:ChatMessage[] messages = [{role: "user", content: prompt}];
    ai:ChatAssistantMessage|error response = model->chat(messages);

    if response is error {
        return error("AI generation failed: " + response.message());
    }

    string? content = response.content;
    if content is string {
        return content;
    } else {
        return error("AI response content is empty.");
    }
}

public function isAIServiceInitialized() returns boolean {
    return anthropicModel !is ();
}
