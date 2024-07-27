from sqlalchemy import create_engine, Column, Integer, String, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

class Guest(Base):
    __tablename__ = 'guests'
    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(30), nullable=False)
    last_name = Column(String(30), nullable=False)
    email = Column(String, nullable=False)
    phone_number = Column(String, nullable=False)
    additional_guests = Column(Integer, default=0)
    approved = Column(Boolean, default=False)

def initialize_db():
    engine = create_engine('sqlite:///database.db')
    Base.metadata.create_all(engine)
    print("Database and table created successfully")

initialize_db()