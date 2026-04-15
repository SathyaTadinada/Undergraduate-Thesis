#!/usr/bin/env python3
from pypdf import PdfReader, PdfWriter
from pypdf.generic import ArrayObject, DictionaryObject, NameObject, NumberObject


def get_page_index(reader, page_ref):
    for i, page in enumerate(reader.pages):
        if page.indirect_reference == page_ref:
            return i
    return None


def copy_outline_recursive(outline_items, writer, reader, page_map, parent=None):
    i = 0
    while i < len(outline_items):
        item = outline_items[i]

        # pypdf represents children as a list following their parent item
        if isinstance(item, list):
            i += 1
            continue

        page_idx = get_page_index(reader, item.page)
        new_page_idx = page_map.get(page_idx, page_idx) if page_idx is not None else 0
        new_item = writer.add_outline_item(item.title, new_page_idx, parent=parent)

        if i + 1 < len(outline_items) and isinstance(outline_items[i + 1], list):
            copy_outline_recursive(
                outline_items[i + 1], writer, reader, page_map, parent=new_item
            )
            i += 2
        else:
            i += 1


def copy_page_labels(thesis_reader, n_thesis, n_design, writer):
    thesis_catalog = thesis_reader.trailer["/Root"]
    if "/PageLabels" not in thesis_catalog:
        return

    thesis_nums = thesis_catalog["/PageLabels"]["/Nums"]

    thesis_labels = {}
    for i in range(0, len(thesis_nums), 2):
        thesis_labels[int(thesis_nums[i])] = thesis_nums[i + 1].get_object()

    # typst emits one label entry per page, collapse to transition points only
    transitions = []
    prev_style = None
    for idx in sorted(thesis_labels.keys()):
        obj = thesis_labels[idx]
        style = obj.get("/S", None)
        if idx == 0 or str(style) != str(prev_style):
            transitions.append((idx, obj))
            prev_style = style

    new_nums = ArrayObject()
    for page_idx, label_obj in transitions:
        if page_idx < n_thesis - 1:
            new_nums.append(NumberObject(page_idx))
            new_nums.append(_make_label_dict(label_obj))

    # design doc pages get no page numbers
    new_nums.append(NumberObject(n_thesis - 1))
    new_nums.append(DictionaryObject({NameObject("/Type"): NameObject("/PageLabel")}))

    last_label = thesis_labels.get(n_thesis - 1)
    if last_label is not None:
        new_nums.append(NumberObject(n_thesis - 1 + n_design))
        new_nums.append(_make_label_dict(last_label))

    writer._root_object[NameObject("/PageLabels")] = DictionaryObject(
        {NameObject("/Nums"): new_nums}
    )


def _make_label_dict(source_obj):
    d = DictionaryObject()
    d[NameObject("/Type")] = NameObject("/PageLabel")
    if "/S" in source_obj:
        d[NameObject("/S")] = NameObject(str(source_obj["/S"]))
    if "/St" in source_obj:
        d[NameObject("/St")] = NumberObject(int(source_obj["/St"]))
    if "/P" in source_obj:
        d[NameObject("/P")] = source_obj["/P"]
    return d


def main():
    thesis_path = "thesis.pdf"
    design_path = "assets/design-document.pdf"
    output_path = "thesis-final.pdf"

    thesis_reader = PdfReader(thesis_path)
    design_reader = PdfReader(design_path)

    n_thesis = len(thesis_reader.pages)
    n_design = len(design_reader.pages)

    writer = PdfWriter()

    for i in range(n_thesis - 1):
        writer.add_page(thesis_reader.pages[i])
    for i in range(n_design):
        writer.add_page(design_reader.pages[i])
    writer.add_page(thesis_reader.pages[n_thesis - 1])

    page_map = {i: i for i in range(n_thesis - 1)}
    page_map[n_thesis - 1] = n_thesis - 1 + n_design

    if thesis_reader.outline:
        copy_outline_recursive(thesis_reader.outline, writer, thesis_reader, page_map)

    copy_page_labels(thesis_reader, n_thesis, n_design, writer)

    if thesis_reader.metadata:
        writer.add_metadata(dict(thesis_reader.metadata))

    with open(output_path, "wb") as f:
        writer.write(f)

    print(
        f"Merged {n_thesis} thesis pages + {n_design} design document pages = {n_thesis + n_design} total"
    )
    print(f"Bookmarks: {'copied' if thesis_reader.outline else 'none in source'}")
    print(f"Output: {output_path}")


if __name__ == "__main__":
    main()
