import os
import asyncpg
import random
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

# Load .env if the variables are not set
if not os.getenv("DB_HOST"):
    load_dotenv()

# DB - Manage the connection to the database
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create the connection pool
    app.state.pool = await asyncpg.create_pool(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_DATABASE"),
        min_size=1,
        max_size=10
    )
    yield
    # Close the pool
    await app.state.pool.close()

# Initialize the app with the lifespan
app = FastAPI(lifespan=lifespan)

# Allow the front-end requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# GET - Get a random message from the database
@app.get("/message")
async def root():
    # Get a random number
    message_num = random.randint(1, 3)
    async with app.state.pool.acquire() as conn:
        # Create the query
        message = await conn.fetchrow(
            "SELECT * FROM messages WHERE id = $1", 
            message_num
        )
        # Verify if the message exists
        if not message:
            raise HTTPException(status_code=404, detail="Message not found")
        # Return the message
        print(message['content'])
        return {"message": message['content']}
