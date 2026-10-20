export default function App() {
  return (
    <main className="faqja">
      <h1>Sistemi për Menaxhimin e Fermerëve dhe Produkteve Bujqësore</h1>
      <p className="nenshkrim">
        Struktura fillestare e frontend-it (Raporti Teknik 1). Funksionet e plota
        implementohen pas këtij raporti.
      </p>
      <section className="kutia">
        <p>Përdoruesit: Administrator, Fermer, Blerës</p>
        <p>Modulet e planifikuara:</p>
        <ul>
          <li>Regjistri i fermerëve</li>
          <li>Katalogu i produkteve bujqësore</li>
          <li>Prodhimi (fermër × produkt)</li>
          <li>Ofertat për shitje</li>
          <li>Porositë e blerësve</li>
        </ul>
      </section>
    </main>
  );
}
