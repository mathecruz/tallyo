import { Component, inject, signal, HostListener } from '@angular/core';
import { TableModule } from 'primeng/table';
import { Tag } from 'primeng/tag';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import {
  Category,
  RecordResponseItem,
  TallyoApiService,
  Transaction,
} from '../../tallyo-api.service';
import { Paginator, PaginatorState } from 'primeng/paginator';
import { Card } from 'primeng/card';
import { Button } from 'primeng/button';
import { Dialog } from 'primeng/dialog';
import { InputNumber } from 'primeng/inputnumber';
import { InputText } from 'primeng/inputtext';
import { Select } from 'primeng/select';
import { DatePicker } from 'primeng/datepicker';
import { ToastService } from '../../services/toast.service';

@Component({
  selector: 'app-records',
  imports: [
    TableModule,
    Tag,
    CurrencyPipe,
    DatePipe,
    Paginator,
    Card,
    Button,
    Dialog,
    InputNumber,
    InputText,
    Select,
    DatePicker,
    ReactiveFormsModule,
  ],
  templateUrl: './records.component.html',
  styleUrl: './records.component.scss',
})
export class RecordsComponent {
  eyes = signal(true);
  balance = signal(0);
  records: RecordResponseItem[] = [];
  tallyoApiService = inject(TallyoApiService);
  toast = inject(ToastService);
  formBuilder = inject(FormBuilder);
  first = signal<number>(0);
  rows = signal<number>(10);
  totalRecords = signal<number>(0);
  totalIn = signal<number>(0);
  totalExpenses = signal<number>(0);
  hideTag = signal(false);
  isMobile = signal(false);

  editDialogVisible = signal(false);
  saving = signal(false);
  editingId: number | null = null;
  editForm = this.formBuilder.group({
    amount: [null as number | null, [Validators.required, Validators.min(0)]],
    description: ['', [Validators.required, Validators.pattern(/\S/)]],
    transaction: ['OUT' as Transaction, Validators.required],
    category: ['GENERAL' as Category],
    transactionDate: [null as Date | null, Validators.required],
  });

  transactionOptions: { label: string; value: Transaction }[] = [
    { label: 'Saída', value: 'OUT' },
    { label: 'Entrada', value: 'IN' },
  ];

  categoryOptions: { label: string; value: Category }[] = [
    { label: 'Geral', value: 'GENERAL' },
    { label: 'Custos fixos', value: 'FIXED_COSTS' },
    { label: 'Conforto', value: 'COMFORT' },
    { label: 'Prazeres', value: 'PLEASURES' },
    { label: 'Metas', value: 'GOALS' },
    { label: 'Liberdade financeira', value: 'FINANCIAL_FREEDOM' },
    { label: 'Conhecimento', value: 'KNOWLEDGE' },
  ];

  constructor() {
    this.checkScreenSize();
    this.populatePaginator();
  }

  @HostListener('window:resize', ['$event'])
  onResize(event: any) {
    this.checkScreenSize();
  }

  private checkScreenSize() {
    this.isMobile.set(window.innerWidth <= 1280);
  }

  private populatePaginator() {
    this.tallyoApiService
      .getRecords(this.first(), this.rows())
      .subscribe((body) => {
        if (body.items.length > 0) {
          this.records = body.items.map((item) => ({
            ...item,
            tag: item.transaction === 'OUT' ? 'Saída' : 'Entrada',
            icon:
              item.transaction === 'OUT'
                ? 'pi pi-arrow-circle-down'
                : 'pi pi-arrow-circle-up',
          }));

          this.totalRecords.set(body.totalRecords);
          this.totalIn.set(body.totalIn);
          this.totalExpenses.set(body.totalExpenses);

          this.balance.set(this.totalIn() - this.totalExpenses());
        }
      });
  }

  changeEyes() {
    this.eyes.update((value) => !value);
  }

  onPageChange($event: PaginatorState) {
    this.first.set($event.page || 0);
    this.rows.set($event.rows || 10);
    this.populatePaginator();
  }

  editRecord(record: RecordResponseItem) {
    this.editingId = record.id;
    this.editForm.reset({
      amount: record.amount,
      description: record.description,
      transaction: record.transaction,
      // IN records are stored with NONE, which is not a choice for OUT
      category: record.category === 'NONE' ? 'GENERAL' : record.category,
      transactionDate: this.parseIsoDate(record.transactionDate),
    });
    this.editDialogVisible.set(true);
  }

  saveRecord() {
    if (this.editForm.invalid || this.editingId == null) {
      this.editForm.markAllAsTouched();
      return;
    }

    const { amount, description, transaction, category, transactionDate } =
      this.editForm.getRawValue();

    this.saving.set(true);
    this.tallyoApiService
      .updateRecord(this.editingId, {
        amount: amount!,
        description: description!.trim(),
        transaction: transaction!,
        category: transaction === 'IN' ? null : category,
        transactionDate: this.toIsoDate(transactionDate!),
      })
      .subscribe({
        next: () => {
          this.saving.set(false);
          this.editDialogVisible.set(false);
          this.toast.success('Tudo certo!', 'Registro atualizado');
          this.populatePaginator();
        },
        error: () => {
          this.saving.set(false);
          this.toast.error('Ops!', 'Não foi possível atualizar o registro');
        },
      });
  }

  // Built from the parts so the date is not shifted by the browser time zone
  private parseIsoDate(value: string): Date {
    const [year, month, day] = value.split('-').map(Number);
    return new Date(year, month - 1, day);
  }

  private toIsoDate(date: Date): string {
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day}`;
  }

  deleteRecord(id: number) {
    this.tallyoApiService.deleteRecord(id).subscribe(() => {
      this.populatePaginator();
    });
  }
}
