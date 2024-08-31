# LangChain BigQuery Assistant

This project is a LangChain-based application that connects to BigQuery to query data from a data warehouse, utilizes a vector database for storing and retrieving knowledge base information, and provides intelligent responses to user queries. The system is designed to be integrated with Slack for easy user interaction.

## Features

- Connect to BigQuery and execute queries based on natural language input
- Utilize a vector database to store and retrieve relevant knowledge base information
- Generate context-aware responses using LLM technology
- (Planned) Slack integration for user-friendly interaction

## Prerequisites

- Python 3.8+
- Google Cloud Platform account with BigQuery access
- OpenAI API key
- (Optional) Slack API credentials

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/langchain-bigquery-assistant.git
   cd langchain-bigquery-assistant
   ```

2. Create and activate a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```

3. Install the required packages:
   ```
   pip install -r requirements.txt
   ```

4. Set up your environment variables:
   Create a `.env` file in the project root and add the following:
   ```
   OPENAI_API_KEY=your_openai_api_key
   GOOGLE_APPLICATION_CREDENTIALS=path/to/your/bigquery/credentials.json
   BIGQUERY_PROJECT_ID=your_bigquery_project_id
   BIGQUERY_DATASET_ID=your_bigquery_dataset_id
   ```

5. Prepare your BigQuery service account key:
   - Follow the instructions in the Google Cloud documentation to create a service account and download the JSON key file.
   - Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of this JSON file.

6. Set up the vector database:
   - (Instructions for setting up and populating your chosen vector database, e.g., Pinecone, Weaviate, etc.)

## Usage

Run the main application:

```
python app.py
```

The application will prompt you to enter queries. It will then process these queries, fetch relevant information from BigQuery and the knowledge base, and provide responses.

## Project Structure

```
langchain-bigquery-assistant/
├── langchain/
│ └── ... (langchain-specific code)
│
├── .gitignore
├── requirements.txt
├── .env (not in version control)
├── service-account.json (not in version control)
└── README.md
```

## Future Plans

1. Slack Integration: Implement a Slack bot that allows users to interact with the assistant directly from their Slack workspace.

2. Enhanced Knowledge Base: Expand the vector database to include more comprehensive information about data schemas, business metrics, and common queries.

3. Query Optimization: Implement features to optimize generated BigQuery SQL for better performance.

4. User Feedback Loop: Add functionality for users to provide feedback on responses, which can be used to improve the system over time.

5. Multi-Language Support: Extend the assistant to understand and respond in multiple languages.

## Contributing

Contributions to this project are welcome! Please fork the repository and submit a pull request with your proposed changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.