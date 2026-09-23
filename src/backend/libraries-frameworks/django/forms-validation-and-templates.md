# Forms, Validation, and Templates

## Forms as an Input Boundary

A Django form parses untrusted input, converts values to Python types, reports
validation errors, and can render HTML controls. Read `cleaned_data` only after
`is_valid()` succeeds.

```python
from django import forms


class TransferForm(forms.Form):
    recipient = forms.EmailField()
    amount = forms.DecimalField(min_value=0.01, max_digits=12, decimal_places=2)

    def clean_recipient(self):
        return self.cleaned_data["recipient"].lower()

    def clean(self):
        cleaned = super().clean()
        if cleaned.get("recipient") == self.initial.get("sender"):
            raise forms.ValidationError("Sender and recipient must differ.")
        return cleaned
```

Field cleaning converts the value, runs field validators, and then calls
`clean_<field>()`. `Form.clean()` handles validation that depends on multiple
fields. Validation improves feedback, but database constraints must still
protect persistent invariants and concurrent writes.

## Model Forms

`ModelForm` derives fields and validation from a model. List editable fields
explicitly to avoid exposing a new sensitive model field by accident.

```python
class ProfileForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ["display_name", "timezone"]
```

With `save(commit=False)`, update the instance before saving. If the form has
many-to-many fields, call `save_m2m()` after the instance has a primary key.

```python
profile = form.save(commit=False)
profile.user = request.user
profile.save()
form.save_m2m()
```

Do not trust a hidden form field for ownership, price, permissions, or another
server-controlled value. Derive it from authenticated context or authoritative
data.

## Handling Forms in Views

Bind both posted data and uploaded files, then redirect after a successful write
to avoid duplicate submission on refresh.

```python
def create_document(request):
    if request.method == "POST":
        form = DocumentForm(request.POST, request.FILES)
        if form.is_valid():
            document = form.save(commit=False)
            document.owner = request.user
            document.save()
            return redirect("documents:detail", pk=document.pk)
    else:
        form = DocumentForm()

    return render(request, "documents/create.html", {"form": form})
```

This is the POST/Redirect/GET pattern. It does not make the operation idempotent;
use an idempotency key or unique constraint when duplicate writes matter.

## Templates

Django templates intentionally provide a limited presentation language. Keep
database queries and business decisions out of templates; prepare the context in
the view or a dedicated query layer.

```html
<form method="post">
  {% csrf_token %}
  {{ form.non_field_errors }}
  {{ form.as_div }}
  <button type="submit">Save</button>
</form>
```

HTML output is auto-escaped by default. Avoid `safe`, `mark_safe`, and disabled
auto-escaping for untrusted content. A custom template filter must correctly
declare and preserve escaping behavior.

Templates support inheritance, includes, tags, filters, and context processors.
Context processors should provide cheap, broadly useful values; they run for
many rendered responses.

## CSRF Protection

CSRF protection verifies that unsafe browser requests originate from a trusted
site context. Include `{% csrf_token %}` in internal POST forms and send the CSRF
token for JavaScript requests that use cookie-based authentication. Do not
disable CSRF merely because an endpoint returns JSON.

Bearer-token APIs not authenticated by ambient browser cookies have a different
threat model, but they still need origin, token-storage, and XSS analysis.

## File Uploads

Treat filenames, content types, and file contents as untrusted. Enforce size and
type policies, generate storage names, and serve user media from a separate
domain or storage service where possible. Application validation is not a
substitute for request-size limits at the proxy and web server.

