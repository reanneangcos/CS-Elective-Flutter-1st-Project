import '../models/product.dart';

/// In-memory catalog used by the home and detail screens.
///
/// `const` makes the sample product data immutable and avoids rebuilding these
/// objects each time the UI refreshes.
const products = <Product>[
  Product(
    id: 'strata-one',
    name: 'Strata One',
    colorway: 'Chalk / Sand',
    category: 'Lifestyle',
    price: 6890,
    imageAsset: 'assets/products/strata_one.png',
    description:
        'A quiet everyday low-top built from smooth leather and soft suede. '
        'Its neutral palette, padded collar, and flexible cupsole make it an '
        'easy pair for long city days.',
    materials: 'Premium leather, brushed suede, recycled mesh lining',
    fitNote: 'True to size with a softly padded, everyday fit.',
    sizes: [7, 8, 9, 10, 11],
    releaseLabel: 'Just dropped',
  ),
  Product(
    id: 'flux-runner',
    name: 'Flux Runner',
    colorway: 'Graphite / Voltage',
    category: 'Performance',
    price: 7490,
    imageAsset: 'assets/products/flux_runner.png',
    description:
        'Breathable engineered mesh meets a responsive sculpted midsole. '
        'Voltage accents sharpen a technical runner designed for everyday '
        'movement and lightweight comfort.',
    materials: 'Engineered mesh, molded support cage, responsive foam',
    fitNote: 'Secure performance fit; size up if you prefer extra toe room.',
    sizes: [7, 8, 9, 10, 11, 12],
    releaseLabel: 'Most wanted',
  ),
  Product(
    id: 'court-88',
    name: 'Court 88',
    colorway: 'Cobalt / Cream',
    category: 'Court',
    price: 6290,
    imageAsset: 'assets/products/court_88.png',
    description:
        'An archival court shape refreshed with saturated cobalt panels, '
        'perforated leather, and a classic gum outsole. Familiar proportions '
        'give it a timeless off-court finish.',
    materials: 'Smooth leather, suede details, natural rubber outsole',
    fitNote: 'True to size with a structured court-shoe feel.',
    sizes: [6, 7, 8, 9, 10, 11],
    releaseLabel: 'New in',
  ),
  Product(
    id: 'ridge-form',
    name: 'Ridge Form',
    colorway: 'Clay / Espresso',
    category: 'Trail',
    price: 8290,
    imageAsset: 'assets/products/ridge_form.png',
    description:
        'A rugged trail-inspired build mixing ripstop, suede, and a grippy '
        'oversized outsole. The earthy clay palette brings outdoor utility to '
        'a bold daily silhouette.',
    materials: 'Ripstop textile, water-resistant suede, lugged rubber',
    fitNote: 'Roomy trail fit designed for medium-weight socks.',
    sizes: [7, 8, 9, 10, 11],
    releaseLabel: 'Select edition',
  ),
  Product(
    id: 'aero-knit',
    name: 'Aero Knit',
    colorway: 'Silver / Ice',
    category: 'Performance',
    price: 7790,
    imageAsset: 'assets/products/aero_knit.png',
    description:
        'A light, breathable runner with an airy knit upper and a rolling '
        'foam platform. Cool silver and ice-blue tones keep the technical '
        'shape crisp and versatile.',
    materials: 'Engineered knit, TPU heel support, high-rebound foam',
    fitNote: 'Close athletic fit; size up half a size for casual wear.',
    sizes: [6, 7, 8, 9, 10, 11],
    releaseLabel: 'Fresh arrival',
  ),
  Product(
    id: 'mono-high',
    name: 'Mono High',
    colorway: 'Black / Vintage',
    category: 'Lifestyle',
    price: 7190,
    imageAsset: 'assets/products/mono_high.png',
    description:
        'A clean high-top balancing tumbled leather with hard-wearing canvas. '
        'The vintage-toned sole softens the monochrome upper for an elevated '
        'daily uniform.',
    materials: 'Tumbled leather, canvas quarter panels, rubber cupsole',
    fitNote: 'True to size with supportive ankle padding.',
    sizes: [7, 8, 9, 10, 11, 12],
    releaseLabel: 'Archive update',
  ),
  Product(
    id: 'dune-trek',
    name: 'Dune Trek',
    colorway: 'Sand / Deep Teal',
    category: 'Trail',
    price: 8490,
    imageAsset: 'assets/products/dune_trek.png',
    description:
        'Utility-focused trail construction meets an easy neutral palette. '
        'Layered suede and ripstop sit above a deep-lug sole with subtle teal '
        'details for contrast.',
    materials: 'Ripstop nylon, suede overlays, high-traction rubber',
    fitNote: 'Relaxed fit with space for thicker hiking socks.',
    sizes: [7, 8, 9, 10, 11],
    releaseLabel: 'Trail pick',
  ),
  Product(
    id: 'harbor-court',
    name: 'Harbor Court',
    colorway: 'Sage / Cream',
    category: 'Court',
    price: 6590,
    imageAsset: 'assets/products/harbor_court.png',
    description:
        'A relaxed court classic in muted sage suede and warm cream leather. '
        'A caramel gum sole adds vintage character without losing the clean, '
        'wear-anywhere shape.',
    materials: 'Suede, smooth leather, gum rubber outsole',
    fitNote: 'True to size with a slightly generous forefoot.',
    sizes: [6, 7, 8, 9, 10, 11],
    releaseLabel: 'Editor pick',
  ),
];

Product? productById(String? id) {
  // Route parameters arrive as strings. Returning null lets the router show a
  // friendly not-found screen for an unknown product URL.
  for (final product in products) {
    if (product.id == id) return product;
  }
  return null;
}
