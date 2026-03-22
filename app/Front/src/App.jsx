import { useState } from 'react'
import './App.css'
import logo from './assets/LogoSub.png'

function App() {

  const [message, setMessage] = useState('')

  const getMessageFromAPI = async () => {
    try {
      const response = await fetch('http://localhost:8000/message')
      const data = await response.json()
      setMessage(data.message)
    } catch (error) {
      console.error(error)
      setMessage('Error getting message from API')
    }
  }

  return (
    <div className='container'>
      <img src={logo} alt="Logo" />
      <button onClick={getMessageFromAPI}>Get Message</button>
      <h2>{message}</h2>
    </div>
  )
}

export default App
