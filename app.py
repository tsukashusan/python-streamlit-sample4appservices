import asyncio
from openai import AzureOpenAI
import streamlit as st
from logging import getLogger
from dotenv import load_dotenv
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry import trace
import os
load_dotenv()

configure_azure_monitor()

logger = getLogger(__name__)
tracer = trace.get_tracer(__name__)

logger.info("Uncorrelated info log")

client = AzureOpenAI(
    azure_endpoint=os.environ.get("AZURE_OPENAI_ENDPOINT"),
    api_key=os.environ.get("AZURE_OPENAI_API_KEY"),
    api_version=os.environ.get("OPENAI_API_VERSION")
)

def conversation(message):
    
    completion = client.chat.completions.create(
        model=os.environ.get("AZURE_OPENAI_MODEL_NAME"),
        messages=[
            {"role": "system", "content": "You are an AI assistant that helps people find information."},
            {"role": "user", "content": message},
        ],
        stream=True,
    )

    def to_stream_resp(completion):
        content = ""
        result_area = st.empty()
        for chunk in completion:
            if len(chunk.choices) == 0:
                continue
            delta = chunk.choices[0].delta.content
            if delta and delta != "[DONE]":
                content += delta
            #yield json.dumps({"content": content}).replace("\n", "\\n") + "\n"
            #yield content + "\n"
            result_area.write(content)
    to_stream_resp(completion=completion)


# Your Streamlit app code here
if __name__ == '__main__':
    try:
        logger.info("streamlit start")
        q = st.text_area("問い合わせの内容")
        st.button('AIに聞いてみる', on_click=conversation, args=(q,))
    except Exception as e:
        logger.fatal(e)


 
