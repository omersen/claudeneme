import csv, glob, os, numpy as np, onnxruntime as ort
from tokenizers import Tokenizer
rows = list(csv.DictReader(open('madde_sozlugu.csv', encoding='utf-8')))
ids = [r['item_id'] for r in rows]; texts = [r['text'] for r in rows]
# (ad, klasör, havuzlama, önek) : havuzlama model kartlarına göre (BGE: CLS; MiniLM ve E5: ortalama)
models = [('bge-base-en-v1.5', 'm/fast-bge-base-en-v1.5', 'cls', ''), ('bge-base-en', 'm/fast-bge-base-en', 'cls', ''),
          ('bge-small-en', 'm/BAAI-bge-small-en', 'cls', ''), ('all-MiniLM-L6-v2', 'm/sentence-transformers-all-MiniLM-L6-v2', 'mean', ''),
          ('multilingual-e5-large', 'm/fast-multilingual-e5-large', 'mean', 'query: ')]
for ad, kl, hav, onek in models:
    onnx = [p for p in glob.glob(kl + '/**/*.onnx', recursive=True) if not os.path.basename(p).startswith('._')][0]
    tok = Tokenizer.from_file(os.path.join(os.path.dirname(onnx), 'tokenizer.json'))
    tok.enable_padding(); tok.enable_truncation(512)
    enc = tok.encode_batch([onek + t for t in texts])
    ii = np.array([e.ids for e in enc], dtype=np.int64); am = np.array([e.attention_mask for e in enc], dtype=np.int64)
    s = ort.InferenceSession(onnx, providers=['CPUExecutionProvider'])
    feed = {'input_ids': ii, 'attention_mask': am}
    if 'token_type_ids' in [i.name for i in s.get_inputs()]: feed['token_type_ids'] = np.zeros_like(ii)
    H = s.run(None, feed)[0]
    E = H[:, 0, :] if hav == 'cls' else (H * am[..., None]).sum(1) / am.sum(1, keepdims=True)
    E = E / np.linalg.norm(E, axis=1, keepdims=True)
    with open(f'emb_{ad}.csv', 'w', newline='') as fh:
        w = csv.writer(fh); w.writerow(['item_id'] + [f'd{i+1}' for i in range(E.shape[1])])
        for i, r in zip(ids, E): w.writerow([i] + [repr(float(x)) for x in r])
    print(ad, os.path.basename(onnx), E.shape, [i.name for i in s.get_inputs()])
