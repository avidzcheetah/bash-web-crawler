import os
from google import genai
import logging
from dotenv import load_dotenv

load_dotenv()

class AIAnalyzer:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if api_key:
            self.client = genai.Client(api_key=api_key)
            self.model_name = "gemini-2.5-flash"
            self.enabled = True
        else:
            logging.warning("GEMINI_API_KEY not found. AI analysis will be disabled.")
            self.enabled = False

    async def analyze_vulnerability(self, url, snippet, vuln_type):
        if not self.enabled:
            return None

        prompt = f"""
        Analyze the following HTML/Code snippet from the URL: {url}
        Potential Vulnerability detected by heuristic: {vuln_type}
        
        Snippet:
        {snippet}
        
        Is this a real vulnerability or a false positive? 
        Respond with:
        - Result: [VULNERABLE/FALSE POSITIVE]
        - Severity: [CRITICAL/HIGH/MEDIUM/LOW/INFO]
        - Reason: [Short explanation]
        """
        
        try:
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=prompt
            )
            return response.text
        except Exception as e:
            logging.error(f"AI analysis failed: {str(e)}")
            return None
