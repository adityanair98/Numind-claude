"use client";

interface Option {
  label: string;
  value: string;
}

interface CalculatorSelectProps {
  label: string;
  value: string;
  onChange: (value: string) => void;
  options: Option[];
  helper?: string;
  id?: string;
}

export function CalculatorSelect({
  label,
  value,
  onChange,
  options,
  helper,
  id,
}: CalculatorSelectProps) {
  const selectId = id ?? label.toLowerCase().replace(/\s+/g, "-");

  return (
    <div>
      <label htmlFor={selectId} className="block text-sm font-medium text-brand-navy mb-1.5">
        {label}
      </label>
      <select
        id={selectId}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full rounded-button border border-brand-muted/20 bg-brand-bg px-3.5 py-3 text-sm text-brand-navy focus:border-brand-blue focus:outline-none focus:ring-2 focus:ring-brand-blue/20 transition-colors appearance-none bg-[url('data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20fill%3D%22%236B7280%22%20viewBox%3D%220%200%2016%2016%22%3E%3Cpath%20d%3D%22M4.5%206l3.5%203.5L11.5%206%22%20stroke%3D%22%236B7280%22%20stroke-width%3D%221.5%22%20fill%3D%22none%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%3C%2Fsvg%3E')] bg-[length:16px] bg-[right_12px_center] bg-no-repeat pr-10"
      >
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
      {helper && <p className="mt-1 text-xs text-brand-muted">{helper}</p>}
    </div>
  );
}
