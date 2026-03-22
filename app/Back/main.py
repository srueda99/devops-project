from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/message")
async def root():
    message_num = random.randint(1, 3)
    # Connect to DB
    conn = psycopg2.connect(
        host="localhost",
        user="postgres",
        password="password",
        database="postgres"
    )
    # Get random message from DB
    cur = conn.cursor()
    cur.execute("SELECT * FROM messages WHERE id = %s", (message_num,))
    message = cur.fetchone()
    return {"message": message[1]}
