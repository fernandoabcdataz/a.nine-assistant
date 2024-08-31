import os
from dotenv import load_dotenv
from langchain import OpenAI, SQLDatabase, SQLDatabaseChain

# Load environment variables
load_dotenv()

# Initialize OpenAI LLM
llm = OpenAI(temperature=0)

# Connect to BigQuery
project_id = os.getenv("BIGQUERY_PROJECT_ID")
dataset_id = os.getenv("BIGQUERY_DATASET_ID")
db = SQLDatabase.from_uri(f"bigquery://{project_id}/{dataset_id}")

# Create SQL database chain
db_chain = SQLDatabaseChain(llm=llm, database=db, verbose=True)

def generate_sql(prompt):
    try:
        result = db_chain.run(prompt)
        return result
    except Exception as e:
        return f"An error occurred: {str(e)}"

if __name__ == "__main__":
    while True:
        user_prompt = input("Enter your query (or 'quit' to exit): ")
        if user_prompt.lower() == 'quit':
            break
        sql_result = generate_sql(user_prompt)
        print(f"Generated SQL:\n{sql_result}")