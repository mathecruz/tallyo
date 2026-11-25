import { TestBed } from '@angular/core/testing';

import { TallyoApiService } from './tallyo-api.service';

describe('TallyoApiService', () => {
  let service: TallyoApiService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(TallyoApiService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
