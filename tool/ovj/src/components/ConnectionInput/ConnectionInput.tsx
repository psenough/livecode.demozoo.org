import { useState } from 'react';
import './ConnectionInput.css';

interface ConnectionInputProps {
  onAdd: (url: string) => void;
}

export function ConnectionInput({ onAdd }: ConnectionInputProps) {
  const [url, setUrl] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (url.trim()) {
      onAdd(url.trim());
      setUrl('');
    }
  };

  return (
    <form className="connection-input" onSubmit={handleSubmit}>
      <input
        type="text"
        className="connection-input__field"
        placeholder="ws://host:port/path"
        value={url}
        onChange={(e) => setUrl(e.target.value)}
      />
      <button type="submit" className="connection-input__btn">
        Add Connection
      </button>
    </form>
  );
}
