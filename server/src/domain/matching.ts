/**
 * Who may see whom. Approved rules (plan §3):
 *  - the seeker's "Show me" must include the companion's gender, AND
 *  - the companion's "Who can request you" must include the seeker's gender.
 * Non-binary and "Prefer not to say" are only covered by "everyone".
 */

export type Gender = 'woman' | 'man' | 'non_binary' | 'undisclosed';
export type ShowMe = 'women' | 'men' | 'everyone';
export type WhoCanRequest = 'everyone' | 'women' | 'men';

export function showMeIncludes(showMe: ShowMe, gender: Gender): boolean {
  if (showMe === 'everyone') return true;
  return (showMe === 'women' && gender === 'woman') || (showMe === 'men' && gender === 'man');
}

export function whoCanRequestIncludes(whoCanRequest: WhoCanRequest, gender: Gender): boolean {
  if (whoCanRequest === 'everyone') return true;
  return (whoCanRequest === 'women' && gender === 'woman') || (whoCanRequest === 'men' && gender === 'man');
}

export interface SeekerMatchProfile {
  gender: Gender;
  showMe: ShowMe;
  ageMin: number;
  ageMax: number;
}

export interface CompanionMatchProfile {
  gender: Gender;
  whoCanRequest: WhoCanRequest;
  ageYears: number;
}

/** Both directions of the gender rule, plus the seeker's age range. */
export function isVisibleTo(seeker: SeekerMatchProfile, companion: CompanionMatchProfile): boolean {
  return (
    showMeIncludes(seeker.showMe, companion.gender) &&
    whoCanRequestIncludes(companion.whoCanRequest, seeker.gender) &&
    companion.ageYears >= seeker.ageMin &&
    companion.ageYears <= seeker.ageMax
  );
}
