import { useState, useMemo } from 'react';
import type { ShaderFile } from '../../types';
import './Sidebar.css';

interface SidebarProps {
  shaders: ShaderFile[];
  onSelect: (shader: ShaderFile) => void;
  onAdd: (shader: ShaderFile) => void;
  selected?: ShaderFile | null;
}

export function Sidebar({ shaders, onSelect, onAdd, selected }: SidebarProps) {
  const [search, setSearch] = useState('');

  const filtered = useMemo(() => {
    if (!search.trim()) return shaders;
    const q = search.toLowerCase();
    return shaders.filter(
      (s) =>
        s.name.toLowerCase().includes(q) ||
        s.event.toLowerCase().includes(q)
    );
  }, [shaders, search]);

  return (
    <aside className="sidebar">
      <input
        type="text"
        className="sidebar__search"
        placeholder="Search shaders..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      <ul className="sidebar__list">
        {filtered.map((shader) => (
          <li
            key={shader.id}
            className={`sidebar__item ${selected?.id === shader.id ? 'sidebar__item--selected' : ''}`}
            onClick={() => onSelect(shader)}
          >
            {shader.image && (
              <img
                src={shader.image}
                alt={shader.name}
                className="sidebar__thumb"
                loading="lazy"
              />
            )}
            <div className="sidebar__info">
              <span className="sidebar__name">{shader.name}</span>
              <span className="sidebar__event">{shader.event}</span>
            </div>
            <button
              className="sidebar__add"
              onClick={(e) => {
                e.stopPropagation();
                onAdd(shader);
              }}
            >
              Add
            </button>
          </li>
        ))}
      </ul>
    </aside>
  );
}
