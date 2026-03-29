import { useState } from 'react'
import './App.css'
import logo from './assets/LogoSub.png'

function App() {

  const [message, setMessage] = useState('')
  const API_URL = import.meta.env.VITE_API_URL

  const getMessageFromAPI = async () => {
    try {
      const response = await fetch(`${API_URL}/message`)
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
