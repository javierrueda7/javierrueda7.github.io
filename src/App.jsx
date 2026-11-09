import { Suspense, useEffect, useState } from 'react'
import { PROJECTS } from './registry.js'

function useHashProject() {
  const read = () => {
    const id = location.hash.replace(/^#\/?/, '')
    return PROJECTS.find((p) => p.id === id) ?? PROJECTS[0]
  }
  const [project, setProject] = useState(read)
  useEffect(() => {
    const on = () => setProject(read())
    window.addEventListener('hashchange', on)
    return () => window.removeEventListener('hashchange', on)
  }, [])
  return project
}

function useTheme() {
  const [theme, setTheme] = useState(() => {
    try {
      return localStorage.getItem('theme') || 'auto'
    } catch {
      return 'auto'
    }
  })
  useEffect(() => {
    const root = document.documentElement
    if (theme === 'auto') root.removeAttribute('data-theme')
    else root.setAttribute('data-theme', theme)
    try {
      localStorage.setItem('theme', theme)
    } catch {
      /* sin almacenamiento: no pasa nada */
    }
  }, [theme])
  return [theme, setTheme]
}

const STATUS_CLASS = { live: 'b-live', dev: 'b-dev', test: 'b-test' }

export default function App() {
  const project = useHashProject()
  const [theme, setTheme] = useTheme()
  const [run, setRun] = useState(0)
  const { Sim } = project

  useEffect(() => {
    setRun(0)
    document.title = `${project.name} · Demos · Javier Rueda`
  }, [project.id])

  const nextTheme = { auto: 'dark', dark: 'light', light: 'auto' }[theme]

  return (
    <div className="lab" style={{ '--app': project.accent }}>
      <header className="lab-nav">
        <a className="brand" href="../">
          javier<span>.</span>rueda
        </a>
        <span className="lab-title">Demos interactivas</span>
        <button className="chip" onClick={() => setTheme(nextTheme)} aria-label="Cambiar tema">
          tema: {theme === 'auto' ? 'sistema' : theme === 'dark' ? 'oscuro' : 'claro'}
        </button>
      </header>

      <div className="lab-body">
        <nav className="lab-list" aria-label="Proyectos">
          <p className="lab-hint">Datos 100% ficticios. Nada aquí toca una base de datos real.</p>
          {PROJECTS.map((p) => (
            <a
              key={p.id}
              href={`#/${p.id}`}
              className={`proj ${p.id === project.id ? 'on' : ''}`}
              aria-current={p.id === project.id ? 'page' : undefined}
            >
              <span className="dot" style={{ background: p.accent }} />
              <span>
                <strong>{p.name}</strong>
                <small>{p.tagline}</small>
              </span>
            </a>
          ))}
        </nav>

        <main className="lab-stage">
          <div className={`device ${project.device}`}>
            {project.device === 'phone' && <div className="notch" />}
            <div className="screen">
              <Suspense fallback={<div className="loading">Cargando demo…</div>}>
                <Sim key={`${project.id}-${run}`} />
              </Suspense>
            </div>
          </div>
          <button className="chip reset" onClick={() => setRun((r) => r + 1)}>
            Reiniciar demo
          </button>
        </main>

        <aside className="lab-info">
          <span className={`badge ${STATUS_CLASS[project.status]}`}>{project.statusLabel}</span>
          <h1>{project.name}</h1>
          <p>{project.about}</p>

          <h2>Pruébala</h2>
          <ol>
            {project.try.map((t) => (
              <li key={t}>{t}</li>
            ))}
          </ol>

          <h2>Stack</h2>
          <p className="tags">
            {project.stack.map((s) => (
              <span key={s}>{s}</span>
            ))}
          </p>

          <h2>Lo que no se simula</h2>
          <p className="muted">{project.simulated}</p>

          {project.link && (
            <a className="btn" href={project.link.href} target="_blank" rel="noopener">
              {project.link.label}
            </a>
          )}
        </aside>
      </div>
    </div>
  )
}
