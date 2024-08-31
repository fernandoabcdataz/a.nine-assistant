import yaml
from google.cloud import bigquery
from google.oauth2 import service_account
from langchain.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter

# load the semantic model
with open('payments.yaml', 'r') as file:
    semantic_model = yaml.safe_load(file)

# convert the semantic model to a string
semantic_model_str = yaml.dump(semantic_model)

# split the text into chunks
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
texts = text_splitter.split_text(semantic_model_str)

# initialize openai embeddings
embeddings = OpenAIEmbeddings()

# generate embeddings for each chunk
embedded_texts = embeddings.embed_documents(texts)

# set up bigquery client
credentials = service_account.Credentials.from_service_account_file(
    '../../service_account.json',
    scopes=["https://www.googleapis.com/auth/cloud-platform"],
)

client = bigquery.Client(credentials=credentials, project=credentials.project_id)

# define the schema for the bigquery table
schema = [
    bigquery.SchemaField("chunk_id", "INTEGER", mode="REQUIRED"),
    bigquery.SchemaField("text_chunk", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("embedding", "FLOAT", mode="REPEATED"),
]

# create a new dataset for shared knowledge (if it doesn't exist)
dataset_id = "shared_knowledge"
dataset_ref = client.dataset(dataset_id)
try:
    client.get_dataset(dataset_ref)
except Exception:
    dataset = bigquery.Dataset(dataset_ref)
    dataset.location = "US"  # Specify the desired location
    client.create_dataset(dataset)

# create a new table for the semantic model embeddings
table_id = f"{client.project}.{dataset_id}.payments_semantic_model_embeddings"
table = bigquery.Table(table_id, schema=schema)
table = client.create_table(table, exists_ok=True)

# prepare the rows for insertion
rows_to_insert = [
    {"chunk_id": i, "text_chunk": chunk, "embedding": embedding}
    for i, (chunk, embedding) in enumerate(zip(texts, embedded_texts))
]

# insert the data into BigQuery
errors = client.insert_rows_json(table, rows_to_insert)

if errors == []:
    print("knowledge base model uploaded successfully to BigQuery")
else:
    print("errors occurred while uploading: ", errors)